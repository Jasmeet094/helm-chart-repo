#!/bin/bash

# s3 log rotate and pruning
#

INSTANCE_ID=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
AZ=`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo "${AZ%?}"`"
NAME_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region $REGION | grep Value | awk '{print $2;}' | sed 's/\,//g' | sed 's/\"//g'`"
NOW=$(date +"%m_%d_%Y")

#FILES=( "/home/mhc/logs" "/var/log/" )
FILES=( "/var/log/" )
STATUS=0

for i in "${FILES[@]}"
do
	aws s3 cp "$i" s3://mhc-logs/$REGION/$NAME_VALUE/ --recursive --exclude=* --include "*.gz" --region $REGION
	if [ $? -eq 0 ]
	then
            sleep 1
	else
	    MESSAGE="Hello, The current day is $NOW. The copy of logs off the server has failed for the path $i. It failed to copy logs to s3://mhc-logs/ on $NAME_VALUE ($INSTANCE_ID) in $REGION in $AZ"
	    SUBJECT="Logs copy failed on $NAME_VALUE ($INSTANCE_ID) in $REGION"
	    aws sns publish --topic-arn "arn:aws:sns:us-west-2:913835907225:Admin_Alerts" --subject "$SUBJECT" --message "$MESSAGE" --region $REGION
	    STATUS=1
	fi
done

if [ $STATUS -eq "0" ]
then
	exit 0
else
	exit 1
fi
