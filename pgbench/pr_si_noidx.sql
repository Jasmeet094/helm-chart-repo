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
-- We use these foreign keys:
-- "partne_ruleClause_id_170e96bc20d619aa_fk_partners_ruleclause_id" FOREIGN KEY ("ruleClause_id") REFERENCES partners_ruleclause(id) DEFERRABLE INITIALLY DEFERRED
-- "partners_rule_client_id_1216990c_fk_partners_client_id" FOREIGN KEY (client_id) REFERENCES partners_client(id) DEFERRABLE INITIALLY DEFERRED
-- "partners_rule_formula_id_d7f97c36_fk_partners_" FOREIGN KEY (formula_id) REFERENCES partners_standaloneformula(id) DEFERRABLE INITIALLY DEFERRED

-- \set table_name 'partners_rule'
-- \set table_name 'brian.partners_rule_test_without_indexes'
\set maximum_offset 1000

SELECT id AS partners_client_id FROM (
    SELECT id FROM partners_client
) x ORDER BY RANDOM() LIMIT 1 \gset

SELECT id AS partners_standaloneformula_id FROM (
    SELECT id FROM partners_standaloneformula LIMIT :maximum_offset
) x ORDER BY RANDOM() LIMIT 1 \gset

SELECT id AS partners_ruleclause_id FROM (
    SELECT id FROM partners_ruleclause LIMIT :maximum_offset
) x ORDER BY RANDOM() LIMIT 1 \gset

INSERT INTO brian.partners_rule_test_without_indexes("ruleClause_id", "negative", "operation", "value", "ruleType", "attributeName", "formula_id", "client_id", "useSelfReportedValues")
    VALUES(:partners_ruleclause_id, false, 'EQ', 'True', 'FO', 'boolean', :partners_standaloneformula_id, :partners_client_id, true);
