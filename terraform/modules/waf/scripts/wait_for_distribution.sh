#!/bin/bash

if [ ! $1 ]; then
    echo "Please provide Cloudfront distribution ID as the only argument"
    exit -1
fi

DIST_ID=$1
STATUS="NOT_READY"
until [ "${STATUS}x" == "Deployedx" ]; do
    STATUS=$(aws cloudfront get-distribution --id $DIST_ID --query 'Distribution.Status' --output text)
    sleep 30
done

echo "{\"Distribution\": \"$DIST_ID\", \"Status\": \"$STATUS\"}"
exit 0
