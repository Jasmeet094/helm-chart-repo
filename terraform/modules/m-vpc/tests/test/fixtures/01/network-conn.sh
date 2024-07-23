#!/bin/bash 
# This script is built to hold up a terraform deployment until either an instance can
# connect to the internet or an amount of time has passed
sudo yum update -y -q
sudo yum install -y nc

ATTEMPT=0

while [[ ! `nc -zv google.com 80` && $ATTEMPT -le 10 ]]
do
  echo "Attempt #$ATTEMPT: Couldn't talk to google, sleeping 20 seconds"
  ATTEMPT=$(( ATTEMPT + 1 ))
  sleep 20
done
