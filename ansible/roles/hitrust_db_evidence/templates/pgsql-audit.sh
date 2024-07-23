#!/bin/bash

echo "Getting PostgreSQL version information"
psql -c 'select version();'

echo "Getting Postgresql user info"
psql -c '\du+'

echo "Getting application users"
echo -e "SELECT username FROM auth_user WHERE is_superuser = true AND last_login < CURRENT_DATE - interval '3 months' AND username NOT LIKE '%pool%' AND is_active = true;" | psql  -d djangostack

echo -e "select schemaname as table_schema,
    relname as table_name,
    pg_size_pretty(pg_total_relation_size(relid)) as total_size,
    pg_size_pretty(pg_relation_size(relid)) as data_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid))
      as external_size
from pg_catalog.pg_statio_user_tables
order by pg_total_relation_size(relid) desc,
         pg_relation_size(relid) desc
limit 50;" | psql  -d djangostack

{% if dryrun %}
echo "skipping delete due to dryrun flag"
{% else %}
# delete command
#psql -d djangostack -c "UPDATE auth_user SET is_active = false WHERE is_superuser = true AND last_login < CURRENT_DATE - interval '3 months' AND username NOT LIKE '%pool%' AND is_active = true;"

echo -e "SELECT username FROM auth_user WHERE is_superuser = true AND last_login < CURRENT_DATE - interval '3 months' AND username NOT LIKE '%pool%' AND is_active = true;" | psql  -d djangostack
{% endif %}
