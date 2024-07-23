#!/bin/bash

##
# Foghorn Ubuntu 14.04 Startup Script
# 2015-10
# aws-cli/1.9.2 Python/2.7.6
##
# Install AWS CLI
#apt-get install unzip -y
#curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
#unzip awscli-bundle.zip
#./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
##
# Store instance metadata...
INSTANCE_ID=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
IPV4=`wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4`
AZ=`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$AZ\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
# Get the tag values for this instance
NAME_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region $REGION | grep Value | awk '{print $2;}' | sed 's/\,//g' | sed 's/\"//g'`"
##
# Set hostname for current
hostname $NAME_VALUE
# Set hostname for future
echo "$NAME_VALUE" > /etc/hostname
# Update hosts with IP and hostname
sed -i "1s/^/$IPV4 $NAME_VALUE \n/" /etc/hosts
##
exit 0