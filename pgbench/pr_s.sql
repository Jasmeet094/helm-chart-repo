SELECT id AS client_id FROM (
    SELECT id FROM partners_client LIMIT 10000
) x ORDER BY RANDOM() LIMIT 1 \gset

