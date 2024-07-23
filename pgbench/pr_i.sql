-- This script is used with pgBench to test the partners_rule table.
-- At the time of this writing, that table looks approximately like the following (incomplete) definition:
-- CREATE TABLE partners_rule(
--      id                          bigint generated as identity
--     ruleClause_id                bigint
--     negative                     boolean not null default false
--     operation                    character varying(2) not null default 'EQ'
--     value                        text
--     healthStatistic_id           bigint
--     incentive_id                 bigint
--     fileType_id                  bigint
--     fileField                    character varying(50)
--     ruleType                     character varying(8) not null
--     attributeName                text
--     healthRisk_id                bigint
--     healthAssessmentQuestion_id  bigint
--     customFieldDef_id            bigint
--     gapInCare_id                 bigint
--     quiz_id                      bigint
--     activityPlanLevel_id         bigint
--     useSelfReportedValues        boolean  not null
--     assessmentScore_id           bigint
--     notApplicableTopic_id        bigint
--     clientAssessment_id          bigint
--     clientSurvey_id              bigint
--     reimbursement_id             bigint
--     messageConfig_id             bigint
--     careGap_id                   bigint
--     childAttribute               text
--     pointsPlanLevel_id           bigint
--     pickNCollection_id           bigint
--     pickNParent_id               bigint
--     valueDataElement_id          bigint
--     clientRaffle_id              bigint
--     clientRafflePrizeLevel_id    bigint
--     clientReward_id              bigint
--     clientStoreItem_id           bigint
--     clientCalendar_id            bigint
--     program_id                   bigint
--     relativeSource               text
--     standaloneRuleSet_id         bigint
--     formula_id                   bigint
--     ssoConfig_id                 bigint
--     clientCurrency_id            bigint
--     client_id                    bigint
-- )

\set partners_ruleclause_id random(110004514959, 110004515058)
\set partners_client_id random(110000000128, 110000000207)
\set partners_standaloneformula_id random(110000142858, 110000143358)

INSERT INTO partners_rule("ruleClause_id", "negative", "operation", "value", "ruleType", "attributeName", "formula_id", "client_id", "useSelfReportedValues")
    VALUES(:partners_ruleclause_id, false, 'EQ', 'True', 'FO', 'boolean', :partners_standaloneformula_id, :partners_client_id, true);
