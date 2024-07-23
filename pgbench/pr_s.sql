SELECT id AS client_id FROM (
    SELECT id FROM partners_client LIMIT 10000
) x ORDER BY RANDOM() LIMIT 1 \gset

SELECT "partners_clientformula"."updated",
    "partners_clientformula"."created",
    "partners_clientformula"."id",
    "partners_clientformula"."client_id",
    "partners_clientformula"."object_id",
    "partners_clientformula"."related_object_name",
    "partners_clientformula"."related_field_name",
    "partners_clientformula"."result_type",
    "partners_clientformula"."formula_tokens",
    "partners_clientformula"."expression_string",
    "partners_clientformula"."text_description",
    "partners_clientformula"."recalculation_mode",
    COALESCE("partners_clientformula"."formula_tokens", NULL) AS "tokens2"
FROM "partners_clientformula"
WHERE (
    "partners_clientformula"."client_id" = :client_id
    AND "partners_clientformula"."recalculation_mode" IN ('depsave')
    AND (
        COALESCE("partners_clientformula"."formula_tokens", NULL) @> '[{"ruleType": "CF", "customFieldDefId": 80000634231, "attributeName": "Attributes"}]'
        OR COALESCE("partners_clientformula"."formula_tokens", NULL) @> '[{"ruleType": "CF", "customFieldDefId": 80000634231}]'
        OR COALESCE("partners_clientformula"."formula_tokens", NULL) @> '[{"ruleType": "CF", "customFieldDefId": 80000634231}]'
        OR COALESCE("partners_clientformula"."formula_tokens", NULL) @> '[{"ruleType": "CFDD", "customFieldDefId": 80000634231}]'
        OR COALESCE("partners_clientformula"."formula_tokens", NULL) @> '[{"ruleType": "CFD", "customFieldDefId": 80000634231}]'
    )
)
