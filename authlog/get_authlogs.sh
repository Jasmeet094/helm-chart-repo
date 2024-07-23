#!/bin/bash

set -uo pipefail

file_date=`date +%Y%m%d`
sns_topic_arn='arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c'

#<<'COMMENT'
rm /home/ubuntu/operations/authlog/log_archive/*.log

for i in `ansible -i /home/ubuntu/operations/ansible/inventory/aws_ec2.yml --list-hosts all_hosts |grep -v hosts`
  do
    echo ${i}pvt.mobileheathconsumer.com
    ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/ansible.key ubuntu@${i}pvt.mobilehealthconsumer.com "sudo cp /root/bin/remote-access-log-${file_date}.txt /tmp; sudo chown ubuntu:ubuntu /tmp/remote-access-log-${file_date}.txt"
    if [ $? -ne 0 ]
    then
        aws sns publish --topic-arn ${sns_topic_arn} --message "get_authlogs.sh - Errors occurred while executing remote copy commands for ${i}pvt.mobileheathconsumer.com"
    fi
    scp -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/ansible.key ubuntu@${i}pvt.mobilehealthconsumer.com:/tmp/remote-access-log-${file_date}.txt /home/ubuntu/operations/authlog/log_archive/${i}-remote-acess-log-${file_date}.txt
    if [ $? -ne 0 ]
    then
        aws sns publish --topic-arn ${sns_topic_arn} --message "get_authlogs.sh - Errors occurred while executing scp transfer from ${i}pvt.mobileheathconsumer.com"
    fi
    ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/ansible.key ubuntu@${i}pvt.mobilehealthconsumer.com "sudo rm /tmp/remote-access-log-${file_date}.txt"
    if [ $? -ne 0 ]
    then
        aws sns publish --topic-arn ${sns_topic_arn} --message "get_authlogs.sh - Errors occurred while deleting temp file from ${i}pvt.mobileheathconsumer.com"
    fi
  done

for file in `ls -1 /home/ubuntu/operations/authlog/log_archive/*.txt`
  do
    cat ${file} >> /home/ubuntu/operations/authlog/log_archive/combined-remote-access-log-${file_date}.log
  done

rm /home/ubuntu/operations/authlog/log_archive/*.txt

/usr/bin/python3 /home/operations/git/implementation/Operations/nightlyReports/authlogShrinker.py ${file_date}

/usr/local/bin/aws sns publish --topic-arn arn:aws:sns:us-west-2:913835907225:Production_Auth_Log_Report  --message "`cat /home/ubuntu/operations/authlog/log_archive/authlog-shrunk-${file_date}.log`" --region us-west-2 --subject "Daily Authlog Report"
