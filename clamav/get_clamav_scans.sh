#!/bin/bash

set -uo pipefail

rm /home/ubuntu/operations/clamav/log_archive/clamscan*.log
rm /home/ubuntu/operations/clamav/daily_scan_report.txt

for i in `ansible -i /home/ubuntu/operations/ansible/inventory/aws_ec2.yml --list-hosts all_hosts |grep -v hosts`
  do
    echo $i.mobhealthinternal.com
    scp -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com:/var/log/clamav/clamscan.log.1 /home/ubuntu/operations/clamav/log_archive/clamscan.$i.log
  done

for i in `ls -1 /home/ubuntu/operations/clamav/log_archive`
  do
    host=`echo ${i} | cut -d '.' -f 2`
    echo -n  "$host " >> /home/ubuntu/operations/clamav/daily_scan_report.txt
    grep -i infected /home/ubuntu/operations/clamav/log_archive/$i >> /home/ubuntu/operations/clamav/daily_scan_report.txt
  done

/usr/local/bin/aws sns publish --topic-arn arn:aws:sns:us-west-2:913835907225:Production_Auth_Log_Report  --message "`cat /home/ubuntu/operations/clamav/daily_scan_report.txt`" --region us-west-2 --subject "Daily Virus Scan Report"
