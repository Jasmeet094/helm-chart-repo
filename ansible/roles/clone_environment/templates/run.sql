psql -h {{tags.Environment}}{{item.dest}}db1pvt.mobilehealthconsumer.com -p 6432 -U bitnami djangostack <<EOF
{{item.statement}}
EOF
exit $?
