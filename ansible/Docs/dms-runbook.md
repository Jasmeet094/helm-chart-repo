<!-- markdownlint-disable MD013 -->
# Migrating EC2 Postgres to RDS Postgres

This runbook describes how to migrate EC2 Postgres instances to RDS. When starting this process, you should have access to an EC2 instance running Postgres and the ability to read and write from the AWS API (eg via the AWS console). At the end of the runbook, you will have an RDS Postgres with all of the same data

At a high level, we need to perform the following tasks:

1. Configure the EC2 Postgres for migration
1. Configure the RDS cluster
1. Configure the DMS job
1. Perform the migration
1. Verify the migration succeeded

## Before You Begin

Verify that you can access the Postgres EC2 instance you want to migrate via SSH and also in the AWS console. You're going to need information about that instance - especially its IP address - many times in this process. The first thing you're going to do is SSH into the EC2 instance, and then you'll likely use the console exclusively up until you start the DMS job, and then you'll be back to your terminal for the rest.

Be sure to perform the following tasks:

- Log into the MHC AWS console
- Connect to the MHC VPN
- Make sure you can get the instance IP easily
- Make sure you can get the RDS hostname easily

## Configure the EC2 Postgres

The only instance configuration is making sure the utilities are installed and those changes I made to postgresql.conf and pg_hba.conf. Test without making those changes. Oh, and adding the dms_test user.

Add a Secrets Manager secret with the PG creds, and make sure port 6432 is accessible from pg_hba.conf - not sure if I changed that.

Scale the volume throughput and IOPS way up, too

## Configure the RDS Cluster

Create a m5 with 64 cores and 256GB of RAM. Make sure to use the right KMS key. Otherwise, make it just like the ones we have now. Create a secrets manager secret with the creds.

## Create the DMS Job

Before you create the tasks, you need:

- A Replication Instance
- EC2 Endpoint
- RDS Endpoint

Then we'll create the two tasks. Make them just like the ones we have now, run the pre-migration assessment, and process the JSON to create the lists.

Consider only creating one task and having pg_dump do all the LOB tables. idk, see how many tables it was actually doing and remember most of hte pgdump ones are blank. Yes, we're doing this. In fact, we'll create two: one with all tables and a premigration assessment to produce the JSON that we'll use to determine what tables we can and can't load via DMS.

### Premigration Assessment Handling

We use this to

1. Generate JSON that lists the tables that DMS is to load
1. Generate the pg_dump command (eg `-t mytable`)

First, we need to get a list of tables with LOB columns

```sql
djangostack=# select max(char_length(value)), max(char_length(summary)) from partners_asynchdbresult;
   max    |  max   
----------+--------
 14619329 | 121462

djangostack=# select max(char_length(value)) from partners_clientcustomfieldvalue;
  max   
--------
 552720

djangostack=# select max(char_length(expression_string)), max(char_length(recalculation_mode)), max(char_length(text_description)), max(char_length(related_object_name)), max(pg_column_size(formula_tokens)) from partners_clientformula;
  max   | max |  max   | max |  max  
--------+-----+--------+-----+-------
 348953 |   7 | 322090 |  26 | 91441
(1 row)

djangostack=# select count(1) from partners_clientformula;

djangostack=# select max(char_length(content)), max(char_length(tag)), max(char_length("systemName")), max(pg_column_size("parameterDefinitions")), max(pg_column_size(attributes)) from partners_clientresource;
   max   | max | max | max | max 
---------+-----+-----+-----+-----
 1966955 | 560 |  67 |     |   5

djangostack=# select max(char_length("errorList")), max(char_length(flags)), max(char_length(batch)), max(char_length(segment)), max(char_length(tag)) from partners_csvfile;
    max    | max | max | max | max 
-----------+-----+-----+-----+-----
 109177967 | 121 |   5 |   5 |   8

djangostack=# select max(char_length(info)), max(char_length("eligibilityMessage")), max(char_length("completionMessage")), max(char_length("selfReportText")), max(char_length(tag)), max(char_length(classifier)), max(char_length("systemName")), max(pg_column_size(attributes)) from public.partners_incentive;
   max   | max | max | max  | max | max | max | max 
---------+-----+-----+------+-----+-----+-----+-----
 1642309 |   0 |   0 | 4165 | 560 |  55 |  96 | 708
(1 row)

djangostack=# select count(1) from public.partners_incentive;
  count   
----------
 46829773

djangostack=# select max(char_length(body)), max(char_length(tag)), max(char_length("systemName")), max(pg_column_size(attributes)) from partners_message;
   max   | max | max | max 
---------+-----+-----+-----
 1089047 | 600 |  59 |   5

```

## Perform the Migration

### Old Way

Update the pg_dump commands to `&>some_file` and do something if they exit nonzero because any errors will be significant.

1. Do the null change or whatever you did
1. Run the schema-only pg_dump
1. Start the other pg_dump
1. Start the DMS jobs
1. Once DMS is complete, run the Python migration script

### New Way

1. Create bucardo and bitnami users with correct passwords and whatever permissions they have (superuser?)
1. Dump and restore the schema
   <!-- markdownlint-capture -->
   <!-- markdownlint-disable MD014 -->
   <!-- markdownlint-disable MD046 -->
   ```shell
   $ sudo su - postgres
   $ PGPORT=6432 pg_dump -Ccsvf schema.sql --quote-all-identifiers djangostack &>pgdump_schema.log
   $ PGPASSWORD="<password>" PGHOST=brian-pgdump-schema-only.ctzs9xz2duaa.us-west-2.rds.amazonaws.com PGDATABASE=postgres PGPORT=5432 psql -f schema.sql &>pgrestore_schema.log
   ```
   <!-- markdownlint-restore -->

   Note that we set the `PGPASSWORD` because it will be required twice: once when it connects to the `postgres` database and once when it connects to the `djangostack` database.

1. Disable triggers and delete indexes
1. Generate pg_dump command by diff-ing the pre-migration assessment and the `\dt`. Also get big lob tables.
1. Start `pg_dump`
1. Start DMS
1. Start pg_restore once pd_dump is done
1. Create indexes
1. Enable triggers

Not sure if it's necessary to disable indexes, but we should probably disable triggers

Also remember to see how long pg_dump takes

### ALTERNATIVE _ CHECK THIS OUT

Our way is too slow. it took 7 hours for the sucessful limited lob job last week.

What if, instead, you use your first pgdump job to create the schema and Then
write a script that creates a separate pg_bench job for each table, watching the
number of running jobs to try to keep 64 running at all times. Each pg_dump uses a text
output format with no compression and pipes to a pg_restore. Turn off the verbose flag
and any output should be meaningful

## Verify the Migration Succeeded

Make sure both DMS jobs were successful, run the verification script

## Notes

- REMEMBER: to get the materialized view and any defined views
- Remove added trust policies to AdministratorAccess role
- Remember to get views and to verify that other types are there
- Remember to verify the permissions

pg_dump -b --clean --if-exists --quote-all-identifiers --serializable-deferrable -Fd -f pgdump -j $(($(nproc)/2)) -t "bucardo.track_public_partners_healthassessmentsection" -t "bucardo.stage_public_partners_standaloneactionchain" -t "bucardo.track_public_partners_incentive" -t "bucardo.uw_tmpmappings" -t "bucardo.track_public_partners_pagelayoutelementimage" -t "public.partners_removeduserrewardcompletion" -t "bucardo.track_public_partners_clientcaregapprovider" -t "bucardo.stage_public_partners_exportschedule" -t "bucardo.track_public_partners_csvfile" -t "public.partners_classifiertilealternative" -t "bucardo.stage_public_partners_mhcadminsecurityconfig" -t "bucardo.track_public_auth_group" -t "bucardo.track_public_partners_clientsurvey" -t "public.anthem_ucfv_del_02162022" -t "public.partners_shard" -t "bucardo.track_public_partners_tiledefinition" -t "bucardo.stage_public_partners_healthassessmentcalculatorquestion" -t "bucardo.track_public_partners_clienthealthassessment" -t "public.django_admin_log" -t "public.integrations_hrsmembermapping" -t "public.hrs_activitytrigger" -t "public.partners_message" -t "public.partners_usercaregap" -t "public.tmp_fulfillments_rm36995_v2" -t "public.rtw_delta_ps01" -t "bucardo.track_public_partners_rulechainentry" -t "bucardo.stage_public_partners_clientcalendarday" -t "bucardo.stage_public_partners_abstractsecurityconfig" -t "bucardo.stage_public_partners_pointsplanlevel" -t "bucardo.stage_public_partners_ruleset" -t "bucardo.track_public_partners_clienttopic" -t "bucardo.stage_public_partners_uploadfieldselection" -t "bucardo.stage_public_partners_branding" -t "bucardo.track_public_partners_partnergroup" -t "bucardo.bucardo_delta_targets" -t "bucardo.track_public_partners_planaccount" -t "bucardo.track_public_partners_clientservice" -t "bucardo.track_public_partners_rhicaregapmapping" -t "public.cwtmp_20181204ui" -t "bucardo.stage_public_partners_sharedadminaccount" -t "bucardo.stage_public_partners_clienthealthrisk" -t "bucardo.track_public_partners_mhcadminsecurityconfig" -t "public.hrs_case" -t "bucardo.track_public_partners_caregap" -t "bucardo.stage_public_partners_plancustomfieldvalue" -t "bucardo.stage_public_partners_pagelayoutelementimage" -t "bucardo.track_public_partners_clientraffle" -t "bucardo.track_public_partners_planlogo" -t "public.partners_userlinkeddevice" -t "bucardo.track_public_partners_clientassessmentquestionoverride" -t "bucardo.stage_public_partners_mhcemail" -t "bucardo.stage_public_partners_pagelayoutgroupmapping" -t "bucardo.stage_public_partners_clientcustomfieldvalue" -t "bucardo.stage_public_partners_clientexternalaccountdata" -t "bucardo.track_public_partners_cardbottomlogo" -t "public.partners_batchmessageoperation" -t "public.partners_eventdefinition" -t "bucardo.track_public_partners_clientthemeelement" -t "bucardo.stage_public_partners_reimbursementperiod" -t "public.partners_clientstore" -t "public.tmp_capcompletions_rm36995" -t "public.cwtmp_20181207uis" -t "bucardo.track_public_partners_clientcalendarday" -t "public.uwtmp_fieldvalues" -t "bucardo.track_public_partners_clientssoconfig" -t "bucardo.stage_public_partners_rulechain" -t "public.rtw_delta1" -t "bucardo.track_public_partners_messageconfig" -t "public.hrs_membergoalintervention" -t "public.tmp_capcompletions_rm36995_v2" -t "bucardo.stage_public_partners_standaloneformula" -t "bucardo.stage_public_partners_clienttaskhandlereligibilitytrigger" -t "bucardo.stage_public_partners_actionchain" -t "bucardo.track_public_partners_customfieldtrigger" -t "public.partners_actiondefinition" -t "bucardo.track_public_partners_shard" -t "bucardo.track_public_partners_clientpagelayoutelement" -t "bucardo.stage_public_partners_inputvalidation" -t "bucardo.track_public_partners_reimbursableprogram" -t "bucardo.stage_public_partners_client" -t "public.aa_usercustomfieldvalue_tmp_07122022" -t "bucardo.stage_public_partners_clientexternalapp" -t "public.partners_externalapp" -t "public.tmp_completions_rm36995" -t "bucardo.stage_public_partners_incentiveactivitythreshold" -t "bucardo.stage_public_partners_trackedexport" -t "bucardo.bucardo_truncate_trigger_log" -t "bucardo.track_public_partners_healthassessmentcalculatorquestion" -t "bucardo.track_public_partners_clientnamedlink" -t "bucardo.stage_public_partners_messagecategory" -t "bucardo.track_public_partners_uploadfieldselection" -t "bucardo.track_public_partners_clientexternalapp" -t "public.dup_oauth" -t "public.mhcclientsecurityconfig_082019" -t "bucardo.track_public_partners_clienttaskhandlereligibilitytrigger" -t "bucardo.track_public_partners_mhcemail" -t "bucardo.track_public_partners_tile" -t "public.partners_rulechainentry" -t "public.kimball_symbolmap_0612" -t "bucardo.track_public_partners_usergroupmembershipmanagercust!5c91a07cb4" -t "bucardo.track_public_partners_incentivecompletiontrigger" -t "bucardo.track_public_partners_healthassessment" -t "public.partners_clientplanexternalaccount" -t "bucardo.stage_public_partners_incentivenoteligibletrigger" -t "bucardo.track_public_partners_clientformula" -t "public.partners_mhcuserbackup" -t "bucardo.track_public_partners_message" -t "public.tmp_capuserincentives_rm36995" -t "bucardo.stage_public_partners_clientvalidation" -t "public.partners_challengeraceactivity" -t "public.uwtmp_doleuserrewardfulfillmenthistory" -t "bucardo.stage_public_partners_clientreward" -t "bucardo.track_public_partners_messagecategory" -t "bucardo.track_public_partners_activityplan" -t "public.partners_rulechain" -t "bucardo.stage_public_partners_clientraffle" -t "bucardo.track_public_partners_clientcalendar" -t "bucardo.track_public_partners_filetype" -t "bucardo.stage_public_auth_group" -t "bucardo.track_public_partners_standaloneformula" -t "public.mhcMailer_messagelog" -t "bucardo.stage_public_partners_clientcurrency" -t "public.integrations_hrsmembergoalmapping" -t "bucardo.stage_public_partners_planyear" -t "public.partners_partnergroup" -t "public.partners_reimbursementplan" -t "public.celery_tasksetmeta" -t "bucardo.track_public_partners_dataelement" -t "public.client_backup" -t "public.partners_userbalance" -t "bucardo.stage_public_partners_messageconfigtrigger" -t "public.partners_userhealthassessmentanswer" -t "public.partners_client" -t "bucardo.stage_public_partners_clientsurvey" -t "public.partners_clientvalidation" -t "bucardo.stage_public_partners_clientcalendar" -t "bucardo.track_public_partners_usergroupmembershipmanagerelig!7be4078b66" -t "bucardo.stage_public_partners_assessmentscore" -t "public.partners_savedexport" -t "public.uwtmp_doleuserrewardfulfillment" -t "bucardo.track_public_partners_challengeteam" -t "bucardo.stage_public_partners_reimbursementplan" -t "bucardo.stage_public_partners_challengeteam" -t "bucardo.track_public_partners_healthassessmentquestionchoice" -t "public.partners_asynchdbresult" -t "public.partners_event" -t "bucardo.track_public_partners_clientcurrency" -t "bucardo.stage_public_partners_schedule" -t "public.partners_reimbursableprogram" -t "bucardo.stage_public_partners_usergroupmembershipmanagerelig!7be4078b66" -t "public.missing_earned_from_urfs" -t "bucardo.bucardo_sequences" -t "bucardo.stage_public_partners_healthassessment" -t "public.facquier_userrewardfulfillment" -t "public.loggers_dblog" -t "public.partners_clienthealthassessment" -t "bucardo.stage_public_partners_pointsplan" -t "public.partners_incentive" -t "bucardo.stage_public_partners_pickncollection" -t "public.partners_partnercsvfile" -t "bucardo.track_public_partners_trackedexport" -t "bucardo.track_public_partners_schedule" -t "bucardo.stage_public_partners_clientresource" -t "bucardo.stage_public_partners_clienthealthassessment" -t "bucardo.track_public_partners_healthassessmentquestion" -t "bucardo.track_public_partners_clientsymbolmap" -t "bucardo.stage_public_partners_clientthemeelement" -t "bucardo.track_public_partners_clienttaskhandlerdefinition" -t "public.missing_client_incentives" -t "public.tmp_userincentives_rm36995" -t "bucardo.stage_public_partners_savedexport" -t "bucardo.stage_public_partners_remindercategory" -t "bucardo.stage_public_partners_incentivecompletiontrigger" -t "bucardo.stage_public_partners_ruleclause" -t "bucardo.track_public_partners_healthassessmentcalculator" -t "bucardo.track_public_partners_sharedadminaccount" -t "public.rtw_delta2" -t "bucardo.stage_public_partners_pointsplanreset" -t "public.partners_userexternalaccount" -t "bucardo.track_public_partners_incentivedonetrigger" -t "bucardo.stage_public_partners_rule" -t "bucardo.track_public_partners_branding" -t "public.temp_usnorphans" -t "bucardo.stage_public_partners_clientassessmentquestionoverride" -t "bucardo.stage_public_partners_clientssoconfig" -t "bucardo.stage_public_partners_clientperiodicemail" -t "bucardo.stage_public_partners_usergroupmembershipmanagercust!5c91a07cb4" -t "bucardo.track_public_partners_clienthealthstatistic" -t "bucardo.track_public_partners_clientstore" -t "bucardo.track_public_partners_partnercsvfile" -t "bucardo.stage_public_partners_attributedefinition" -t "bucardo.stage_public_partners_tile" -t "bucardo.track_public_partners_globalmessage" -t "public.partners_useridcardadditional" -t "bucardo.stage_public_partners_clienthealthriskcoachinfo" -t "bucardo.stage_public_partners_customfieldtrigger" -t "public.uwtmp_doleuserrewardcompletion" -t "bucardo.stage_public_partners_clientmenuitemalternative" -t "public.integrations_hrscodemapping" -t "bucardo.track_public_partners_usergroupmembershipmanager" -t "public.vba_1000_urf" -t "public.timeseries_tmp" -t "bucardo.track_public_partners_clienthealthrisk" -t "bucardo.track_public_partners_messageconfigtrigger" -t "bucardo.track_public_partners_clientraffleprizelevel" -t "bucardo.stage_public_partners_classifiertilealternative" -t "bucardo.track_public_partners_inputvalidation" -t "public.partners_usergroupmembershipmanager" -t "bucardo.track_public_partners_clientvalidation" -t "public.cwtmp_completeduserrewardcompletion" -t "bucardo.stage_public_partners_clientstorecategory" -t "bucardo.stage_public_partners_reimbursableprogram" -t "public.partners_eventdelivery" -t "bucardo.track_public_partners_address" -t "public.partners_userdeductibles" -t "bucardo.stage_public_partners_partnergroup" -t "bucardo.track_public_partners_benefitssummary" -t "bucardo.track_public_partners_incentiveactivitythreshold" -t "bucardo.stage_public_partners_shard" -t "public.partners_bulkcopycsvfile" -t "public.partners_externalaccount" -t "public.hrs_careplandetails" -t "bucardo.stage_public_partners_mhcclientsecurityconfig" -t "bucardo.track_public_partners_ruleset" -t "bucardo.track_public_partners_clienthealthriskcoachinfo" -t "bucardo.stage_public_partners_clientresourcealternativechain" -t "bucardo.track_public_partners_pointsplanlevel" -t "public.partners_clientbranding" -t "bucardo.track_public_partners_pointsplanreset" -t "public.vba_1000_userinc" -t "bucardo.stage_public_partners_globalmessage" -t "bucardo.track_public_partners_clientassessmentadditionalsection" -t "bucardo.track_public_partners_reminder" -t "public.partners_userhealthassessmentanswerhistory" -t "public.erc_uhaa" -t "public.partners_benefitssummary" -t "bucardo.uwtmp_orphanrules" -t "bucardo.track_public_partners_pickncollection" -t "bucardo.stage_public_partners_planlogo" -t "bucardo.track_public_partners_ruleclause" -t "bucardo.stage_public_partners_activityplan" -t "bucardo.stage_public_partners_clienttaskhandlerdefinition" -t "bucardo.bucardo_truncate_trigger" -t "public.tmp_userincentives_rm36995_v2" -t "bucardo.track_public_partners_clientexternalaccountdata" -t "public.partners_csvfile" -t "bucardo.stage_public_partners_clientstore" -t "bucardo.track_public_partners_clientpagelayout" -t "bucardo.stage_public_partners_clientbranding" -t "public.partners_rhicaregapmapping" -t "bucardo.stage_public_partners_clienthealthstatistic" -t "bucardo.track_public_partners_incentiverewardchoice" -t "public.tmp_fulfillmenthistories_rm36995_v2" -t "public.missing_earned_from_urfs_2" -t "bucardo.stage_public_partners_clientcaregap" -t "bucardo.stage_public_partners_incentiverewardchoice" -t "public.partners_usertokenpair" -t "public.partners_clientserviceretryrequest" -t "bucardo.track_public_partners_activityplanlevel" -t "bucardo.stage_public_partners_incentiveeligibilitytrigger" -t "public.cwtmp_20181205uis" -t "public.partners_healthriskquestion" -t "bucardo.track_public_partners_pagelayoutgroupmapping" -t "public.partners_clientresource" -t "bucardo.stage_public_partners_filetype" -t "bucardo.stage_public_partners_clientpagelayoutelement" -t "bucardo.stage_public_partners_healthassessmentcalculator" -t "bucardo.stage_public_partners_reminder" -t "bucardo.stage_public_partners_clienttopic" -t "public.partners_clientcurrency" -t "bucardo.track_public_partners_partner" -t "bucardo.track_public_partners_clientpagelayoutgroup" -t "public.partners_sharedadminaccount" -t "public.partners_healthrisktip" -t "public.partners_trackedlink" -t "public.partners_quizquestionanswer" -t "public.static_site_contactmessage" -t "bucardo.stage_public_partners_clientcaregapprovider" -t "bucardo.stage_public_partners_clientassessmentadditionalsection" -t "bucardo.stage_public_partners_csvfile" -t "bucardo.stage_public_partners_rhicaregapmapping" -t "bucardo.stage_public_partners_benefitssummary" -t "bucardo.track_public_partners_incentiveeligibilitytrigger" -t "public.hrs_memberpolicies" -t "public.partners_clientssoconfig" -t "public.tmp_fulfillmenthistories_rm36995" -t "bucardo.stage_public_partners_cardbottomlogo" -t "bucardo.stage_public_partners_mhcuser" -t "public.anthem_ts_del" -t "bucardo.stage_public_partners_incentive" -t "bucardo.stage_public_partners_address" -t "bucardo.track_public_partners_assessmentscore" -t "bucardo.track_public_partners_clientreward" -t "public.tmp_completions_rm36995_v2" -t "public.cwtmp_completeduserincentive" -t "public.vba_1000_urc" -t "bucardo.track_public_partners_clientresource" -t "bucardo.track_public_partners_planyear" -t "bucardo.stage_public_partners_clientnamedlink" -t "public.partners_clientcalendarday" -t "public.partners_rhiusercaregapmapping" -t "public.partners_lock" -t "public.uwtmp_client_backup_220113" -t "public.vba_1000_urfh1" -t "public.kimball_actionchain_0612" -t "bucardo.stage_public_partners_clienttheme" -t "bucardo.stage_public_partners_clientsymbolmap" -t "public.partners_userinsigniaapirequest" -t "public.partners_clientpagelayoutelement" -t "public.uwtmp_ngcartifacts" -t "bucardo.track_public_partners_savedexport" -t "public.partners_quiz" -t "bucardo.uw_tmprules" -t "bucardo.stage_public_partners_clientpagelayoutgroup" -t "public.hrs_membergoal" -t "bucardo.stage_public_partners_clientmenusection" -t "public.partners_detailedbatchmessageoperation" -t "bucardo.track_public_partners_infocontent" -t "bucardo.stage_public_partners_planaccount" -t "public.vba_1000_urf1" -t "public.vba_1000_urfh" -t "bucardo.stage_public_partners_challengerace" -t "public.partners_gapincaremeasure" -t "bucardo.track_public_partners_clientresourcealternativechain" -t "bucardo.stage_public_partners_caregap" -t "bucardo.stage_public_partners_action" -t "public.partners_mhcemail" -t "bucardo.stage_public_partners_clientcaregapresponse" -t "bucardo.track_public_partners_category" -t "public.djcelery_periodictask" -t "public.partners_address" -t "bucardo.stage_public_partners_plan" -t "bucardo.track_public_partners_clientbranding" -t "bucardo.stage_public_partners_clientstoreitem" -t "public.partners_clientcalendar" -t "bucardo.stage_public_partners_userplan" -t "public.anthem_ts_value_del" -t "public.partners_clientexternalaccountdata" -t "public.partners_caregap" -t "bucardo.track_public_partners_plan" -t "public.partners_eventsubscription" -t "public.partners_clientformula" -t "public.uw_180924_incdel" -t "public.cw_dup_ui" -t "public.tmp_capfulfillments_rm36995" -t "bucardo.track_public_partners_clientmenuitemalternative" -t "bucardo.track_public_partners_clientstoreitem" -t "bucardo.track_public_partners_pointsplan" -t "public.partners_plan" -t "bucardo.track_public_partners_clientcaregap" -t "public.standalone_formula_name_change_080522" -t "public.partners_adminaction" -t "public.facquier_urf_history" -t "public.partners_userquizanswers" -t "public.mhc_bad_pgstat" -t "bucardo.stage_public_partners_clientservice" -t "bucardo.stage_public_partners_clienteventdefinition" -t "public.partners_challengecoursemilestone" -t "bucardo.stage_public_partners_clientmenuitem" -t "bucardo.stage_public_partners_healthassessmentquestion" -t "bucardo.track_public_partners_classifiertilealternative" -t "public.partners_healthriskstatistic" -t "public.partners_oauthservice" -t "public.partners_quizquestion" -t "public.partners_oauthserviceappoverride" -t "bucardo.stage_public_partners_clientprogram" -t "bucardo.track_public_partners_clientmenuitem" -t "public.database_speciality" -t "public.partners_userexpiredrefreshtokens" -t "bucardo.uwtmp_orphanassessement" -t "bucardo.stage_public_partners_healthassessmentsection" -t "bucardo.stage_public_partners_rulechainentry" -t "public.uwtmp_dupuis_220909" -t "bucardo.track_public_partners_attributedefinition" -t "bucardo.stage_public_partners_category" -t "bucardo.stage_public_partners_clientraffleprizelevel" -t "bucardo.track_public_partners_action" -t "bucardo.stage_public_partners_messageconfig" -t "public.uwtmp_doleuserincentive" -t "bucardo.stage_public_partners_clientformula" -t "bucardo.track_public_partners_clientstorecategory" -t "bucardo.stage_public_partners_healthassessmentquestionchoice" -t "bucardo.stage_public_partners_tiledefinition" -t "bucardo.stage_public_partners_dataelement" -t "bucardo.track_public_partners_userplan" -t "public.django_session" -t "bucardo.track_public_partners_reimbursementplan" -t "bucardo.stage_public_partners_message" -t "bucardo.stage_public_partners_activityplanlevel" -t "bucardo.stage_public_partners_partnercsvfile" -t "bucardo.track_public_partners_clienttheme" -t "bucardo.track_public_partners_incentivenoteligibletrigger" -t "public.mhcMailer_message" -t "bucardo.track_public_partners_clientmenusection" -t "bucardo.track_public_partners_clienteventdefinition" -t "bucardo.track_public_partners_clientcaregapresponse" -t "public.partners_userlinkedapp" -t "public.tmp_capincentive_uniqueids_rm36995" -t "public.tmp_currencytransactions_rm36995" -t "bucardo.stage_public_partners_usergroupmembershipmanager" -t "bucardo.track_public_partners_exportschedule" -t "public.ucg_dups" -t "bucardo.stage_public_partners_customfielddef" -t "bucardo.track_public_partners_clientcustomfieldvalue" -t "bucardo.track_public_partners_standaloneactionchain" -t "bucardo.track_public_partners_actionchain" -t "bucardo.uw_tmphrsdups" -t "bucardo.track_public_partners_rule" -t "bucardo.track_public_partners_customfielddef" -t "public.partners_infocontent" -t "bucardo.track_public_partners_plancustomfieldvalue" -t "bucardo.stage_public_partners_incentivedonetrigger" -t "public.integrations_anthemhpcc" -t "bucardo.track_public_partners_rulechain" -t "bucardo.track_public_partners_reimbursementperiod" -t "public.partners_userdatabackup" -t "public.partners_useridcard" -t "public.tmp_capfulfillmenthistories_rm36995" -t "public.partners_usercaregapaction" -t "bucardo.track_public_partners_remindercategory" -t "public.tmp_fulfillments_rm36995" -t "bucardo.stage_public_partners_infocontent" -t "public.partners_videocontent" -t "public.partners_assessmentscore" -t "bucardo.stage_public_partners_partner" -t "bucardo.track_public_partners_challengerace" -t "bucardo.stage_public_partners_clientpagelayout" -t "public.partners_userstorepurchase" -t "bucardo.track_public_partners_clientperiodicemail" -t "bucardo"."track_public_partners_client" -t "bucardo"."track_public_partners_abstractsecurityconfig" -t "bucardo"."track_public_partners_clientprogram" -t "bucardo"."track_public_partners_mhcuser" -t "bucardo"."track_public_partners_mhcclientsecurityconfig" -t "public"."uwtmp_packageanalysis2306" djangostack
