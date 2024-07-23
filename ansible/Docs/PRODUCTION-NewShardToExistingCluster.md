# DISABLE BUCARDO FROM STARTING ON DB1 SERVER WHEN PROVISIOING A NEW ENV
# THERE MAY BE ANOTHER ISSUE HERE TO REVIEW, STAY VIGILANT 
# We need to set BUCARDO TO AUTO START ON W1

NEED TO UPDATE AMI to include justin ssh key (user?)

# Edits to make before terraform init (setting shard name/lines IE: ps06/ps13)
1.
```
ansible - Docs - inventory - line 31 (p_s06_hosts)
terraform - app_stack - main.tf - line 58
terraform - app_stack - remote.tf - line 4 and 6 (comments)
terraform - app_stack - variables.tf - line 61
terraform - app_stack - modules - shard - data.tf - comment whole file out
terraform - app_stack - modules - shard - varibales.tf - line 58 and 59 -????? this file is completely 
line 43??
different  or am i looking in the wrong spot?
```
UPDATE DB INSTANCE to t3.large vs t3.medium
# Deploy a new shard in an existing environment
1. terraform plan then terraform apply at app_stack level

cd /git/c-mhc-operations/terraform/app_stack
terraform init

set terraform 0.14.11
terraform plan


######SSTOP STOP STOP
####DONT DO THIS
####DONT READ ANY FURTHER

terraform apply

###brian
##It had to do with the combination of TF version and provider version.. iirc TF attempts to attach the volumes to the #instances before they are ready (eg created but not ready yet), so re-running should not recreate the volumes, and should #recreate the instances
##justin
#  9:22 AM
#I actually think i recall matt having to do this as well twice.
#####

terraform apply (again )



#TO be ignored
*****--W3 - set/check EIP (bug or not assigning from being at our EIP LIMIT. Ticket created to raise limit)
*****--W3 - check volume label/tagging (bug showing w4)

# TO BE FIXED before next run
DB server no mongo volume mounted. attached?
mkfs -t ext4 /dev/sdm
mount /dev/sdm /data-mongodb/
cp /etc/fstab /etc/fstab.bak
Mount without label. (todo would be get it to mount with label)
chown -R mongodb:mongodb /data-mongodb/*
service mongodb start
*****--postgres also was not mounted/good (but I did an odd destroy/create multiple times)
*****--hostnames not set


2. Add new shard to inventory/aws_ec2.yml
    ```bash
        p_s06_hosts: "'Name' in (tags|list) and tags.Environment == 'p' and tags.Ansible == 'True'and tags.Shard == 's06'"
    ```
3. Run graph to make sure it picks up the servers
    ```bash
    # ansible-inventory p_s06_hosts --graph
        @qa_s05_hosts:
        |--qas05db1
        |--qas05w1
        |--qas05w2
    ```
4. Execute ansible application build
    ```bash
    ansible-playbook application.yml -e run_hosts=qa_s05_hosts
    # you will have to run twice for tagging.
    I had the old container (need to pull new container). 
    I had to run: 
    
    ansible-playbook application.yml -e run_hosts=p_s06_hosts --private-key=~/mattkey
    ```
#this is fine, N1 is not created yet, Create N1 from cloned W3
#https://docs.google.com/document/d/1B2JUzPLVM_4zgQVIdEStW77wjU6IV5W0kPMn9pQzGuU/edit bottom of page
fatal: [ps06w1]: FAILED! => {"changed": false, "msg": "Unable to start service mhc-portforwarding.service: Job for mhc-portforwarding.service failed because the control process exited with error code.\nSee \"systemctl status mhc-portforwarding.service\" and \"journalctl -xe\" for details.\n"}


5. From an existing shard run the following
    ```bash
    sudo su - postgres
    cd 14/main 
    pg_dump -s djangostack -p 6432 >/tmp/schema.djangostack.sql
    aws s3 cp /tmp/schema.djangostack.sql s3://mhc-secure/db_schema/p/
    ```
6. on the new shard DB, import that table
    ```bash
    aws s3 cp  s3://mhc-secure/db_schema/p/schema.djangostack.sql /tmp/schema.djangostack.sql
    sudo su - postgres
    psql
### CAN BE DELTED???# Stop connections to DB
# SELECT pg_terminate_backend(pg_stat_activity.pid)
# FROM pg_stat_activity
# WHERE pg_stat_activity.datname = 'djangostack'
#  AND pid <> pg_backend_pid();

# Drop databases (might not be needed, fresh volume nothing exists)

DROP DATABASE djangostack;
DROP DATABASE bucardo;
DROP ROLE bitnami;
DROP ROLE bucardo;

# create databases
# passwords are correct (same as ps10db1)
# Check localsettings.py DB password (seems wrong/needs to be updated after)
# grep PASSWORD /home/mhc/mhc-backend/localsettings.py from exsiting W1 shard
CREATE ROLE bitnami with password 'a1690aef01c815f4';
CREATE DATABASE djangostack;
GRANT ALL on DATABASE djangostack to bitnami;
ALTER ROLE bitnami WITH LOGIN;
CREATE DATABASE bucardo;
CREATE USER bucardo SUPERUSER PASSWORD 'a1690aef01c815f4';
GRANT ALL ON DATABASE bucardo TO bucardo;

    psql -p 6432 -d djangostack -f /tmp/schema.djangostack.sql
    ```
1. Trigger jenkins to deploy and it will fail (be sure to not check bucardo/replication. Replication will not be turned on tell the end and with the guidance of Leena)
  https://jenkins.mobilehealthconsumer.com/job/MHCDeploy/ ??
  #add shard hosts into MHCDeploy - a:ps06w1pvt.mobilehealthconsumer.com,ps06w2pvt.mobilehealthconsumer.com,ps06w3pvt.mobilehealthconsumer.com
1. on the W1 server
    ```bash
    sudo su - mhc
    cd mhc-backend
    


)
# load fixtures. These take some time. These are idempotent. run it as much as you want
# Can they all be  ran at the same time? "Kian - There may be some order dependencies but I don't think so at all.  They should load into separate tables so you can multitask"


./manage.py loaddata partners_fixture.json && ./manage.py loaddata infoContent_fixture.json && ./manage.py loaddata challenge_fixture.json && ./manage.py loaddata code_mapping.json && ./manage.py loaddata cegCondition_fixture.json
#./manage.py loaddata infoContent_fixture.json
#./manage.py loaddata challenge_fixture.json
#./manage.py loaddata code_mapping.json
#./manage.py loaddata cegCondition_fixture.json

./manage.py loaddata theme_fixture.json

# fake out the migrations
***** error'd out need to figure out (django.db.utils.ProgrammingError: column django_content_type.name does not exist)
./manage.py migrate --fake
./manage.py migrate partners

# talk to ulrich before doing this, setups app identifiers, default username. auth_group table
# Load initial data fixture
# ./manage.py loaddata fixtures/initial_fixture.json

# Important: Rename partner from initial fixture to a shard-specific name to avoid name collisions of auth_group objects when syncing to login server (djangstack - partners - auth_group)


    ```
# check with leena on deploying with or without bucardo initially or if we can after the fact of setup down the line.
1. Trigger jenkins to deploy and it will success
1. run post jenkins playbook with the cloned flag which will not restart bucardo
# this will run the ROLE OF JEKINS also
# this runs the initial_fixture.json
    ```
    root@0e18f1e4e767:/data/ansible# ansible-playbook application_deployment_post_jenkins_setup.yml -e run_hosts=p_s06_hosts -e cloned_shard=true  --diff
    # INSERT that should work from the command above but currently doesnt
    # INSERT INTO partners_shard ("id", "name", "baseURL", "adminURL", "idOffset", "secret") select
  '7',
  'Shard 6',
  'https://ps06.mobilehealthconsumer.com',
  'https://ps06w1.mobilehealthconsumer.com',
  '50000000000',
  'AysjuIfAcwoivSikOijponusOtcatlabeakAcbykFecpewecCa'
WHERE NOT EXISTS (SELECT name FROM partners_shard WHERE name = 's06');


    ```
1. on loginDB or SSRDB get the shard1 info
    ```
    select * from partners_shard WHERE id = 1;
    ```
    # Triple check we get the current shard1/base default so its not replicated wrong to other shards
    # there is already a shard6 entry on ps10(others)
1. update the s01 that is put in there
    ```bash
    UPDATE
        partners_shard
        SET "baseURL" = 'https://ots01.mobilehealthconsumer.com',
        "adminURL" = 'https://ots01w1.mobilehealthconsumer.com',
        "secret" = 'xxxxxxxxxxx'
        WHERE id = 1;
    ```
# this currently errors out.
    ./manage.py bootstrapPermissions 
    
    # Check if this is not being done by another fixture already
    # Note: currently partners_clientformula_id_seq doesn't correctly update - use manual alter (use correct value for shard):
    alter sequence partners_clientformula_id_seq restart with 130000000001;

W1 bucardo erroring, password ??

1. Setup MHCADMIN user and other admin accounts; Partner?
1. update the auth_group records for ids 1-5 to rename the shard on it for example "PartnerS8:Full Admin", this is done via the UI 
```bash
djangostack=# select * from auth_group;
id |                       name
----+---------------------------------------------------
  1 | Partner:Full Admin
  2 | Partner:No PHI, No Sensitive Data Admin
  3 | Partner:Read-only Admin
  4 | Partner:Read-only No PHI, No Sensitive Data Admin
  5 | Partner:Password Admin
(5 rows)
````
1. ssh to w1 and run the sync script and press yes????

#install jumpcloud
# JUMPCLOUD PLAYBOOK DID NOT WORK, MANUALLY INSTALLED ON PS14
ansible-playbook install_jumpcloud.yml -e run_hosts=p_s06_hosts --private-key=~/mattkey --diff

#bucardo issues, seems bucardo steps were skipped on db1, bucardo username etc.. stpes might be able to be removed.
#update s06 auth_group ids.

#RAN BUCARDO PLAYBOOK AGAINST DB1/W1
ansible-playbook bucardo_only.yml -e run_hosts=ps14db1 --diff
ansible-playbook bucardo_only.yml -e run_hosts=ps14w1 --diff

Pair leena user to ps06, advise her to start login_sync
leena setup
# TODO manual steps after.

triple check latest localsettings.py updates/changes (previous infrastructure ticket reviews)
Triple check MHC_SAMLCONFIGS/IDP in localsettings.py
Triple check anything that used "psql" cause it needs the -p 6432 right now...
OSSEC
check 

MHC sync cron is missing from W1


HandOff
-developer ssh access [ref: shard set up dialog from slack]

# why did w3 mhc user have an operations ssh key pre-installed? or what is that about?
# (mhc-venv3) mhc@ps06w3:~/.ssh$ vi authorized_keys

######-nginx config (custom headers) [ref: RM 34098]
######W2/W3 localsettings.py db passwords wrong
######add to TG groups?
######review target groups/setup (i beleive these are left over from our previous setup of ps06, no terraform has been run to create those recently)
######alight SSO copy meta files from ps07

Resize instance sizes to match ps07, W2/3 - c6i.4xlarge W1/DB1 - c6i.8xlarge

######Pair Kians user to ps06, for ./manage.py bootstrapPermissions erroring research. (non-issue happens on normal deploy)
triple check all startup values (match ps07 current)
attrmapping and SSO mapping to crypt in localsettings.py
######Nginx - BalancewithBlueLA.com branding/copy from ps07w2/3 TG/CF
######Order cert, install/setup cert.

Monitoring, nagios? cloudwatch? panopta,
resize volumes (match production), make root volumes 60GB, for DB, make mongo 2000, postgres 2000???
######check cronjobs
######rsync scripts
######root@7f04c0ecb90d:/data/ansible# ansible-playbook update_generic_w_server.yml -e run_hosts=p_s14_hosts -e role=migrate_to_efs --check --diff
######/home/mhc/bin/ - missing (sync_script.sh chmod +x, chown mhc) 
######make sure backups are happening - confirmed backups are working

######stunnel was there at this point.
######ansible-playbook update_generic_db_server.yml -e run_hosts='p_s14_hosts' -e role=stunnel_server --diff
######revert static urls
######Have konstantin add to production deploy group (N1?)

Triple check bcbsla branding, nginx, Cloudfront? TG?

mhc-eventbridge service - Not needed for ps06/07
N1?
mhc-portforwarding status - good on W1
file uploads service?

support emails- ???

nightly copy scripts
other reporting scripts?
------DONE------



---Bigger picture TODOS---
Update base ami used to include:
justin/toms ssh keys
maybe some how have jumpcloud agent (but it has to be cleared/not installed or started...)
mini AMI bakery removing a bit of ansible setup code.
    "attribute_map_dir" : "/home/mhc/mhc-backend/samldir/attrmaps",





noTES OCT 2023
ansible sendmail cron was missing (and sync_script)



LEFT over issues - https://mobilehealthc.atlassian.net/browse/BL-152
EFS is mounted/working but the folders/symlinks are not created.




## MISC Prod
1. Setup replication job on SSRDB and ensure it has access
```
nightly-copy2/copy-table-to-ssrdb01.sh 
```
1. Check on new shard the hba.conf to allow access
1. Add to SLA Reports
1. setup nagios
1. setup all the APNs (automated. need to verify on PS10 deployment)


# Georges Notes
```bash
Hi @matt and @justin Here is a list of things to consider when adding a new shard, or when adding more W servers to an existing shard:
Other items that need tweaking when a new shard is created:
- git\implementation\Operations\0_MhCsvUtils\credentialPooler.py
  Around line 99, method translates name of shard (ps01) to a number (1).
  ALSO PING RICHARD to add user IDs/pwds for the credential pooler.
  Could re-write this method to be generic.
- git\implementation\Operations\alight\alight-integration\exportAssessments.py
+ git\implementation\Operations\alight\Unisys\2020\Unisys_exportAssessments.py
+ git\implementation\Operations\alight\Unisys\Unisys_exportAssessments.py
  Around line 81 (sometimes 263), shard name is translated to a number.
  Could re-write this as a method that is generic
- git\implementation\Operations\nightlyReports\serverActivitySummary.py
+ git\implementation\Operations\nightlyReports\serverActivitySummary.sh
  Not sure this report is used anymore.
  Has the servers names (all the *w* servers) hard coded for all the production shards.
- git\implementation\Operations\nightlyReports\sla-report.py
+ git\implementation\Operations\nightlyReports\sla-report-api.py
+ git\implementation\Operations\nightlyReports\sla-report-api.py
  These not used anymore, but have hard-coded names of *W* servers.
- git\implementation\Operations\nightlyReports\sla-report-v2.sh
  This is still used for SLA reporting.  Includes all production *w* servers
  EXCLUDING servers that are dedicated to admin-only processing.
- git\implementation\Operations\ssrdb01\returnToWork\copyData2.py
  Has hard-coded list of all shards that are being used for Return To Work clients.
- git/implementation/Operations/BSC/
  Several scripts in this directory (and subdirectories) assume that BSC only appears on ps05.
  If business with BSC grows and BSC is spread over more shards, these scripts need to be updated.
- git\implementation\Operations\nightlyReports\bsc_getSSO_outbound.sh
  Hard-coded for ps05w1 and ps05w2.  Needs to be changed in more W servers added to ps05
  or if more shards added to support BSC.
