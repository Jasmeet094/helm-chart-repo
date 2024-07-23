#!/bin/bash

set -uo pipefail

#file_date=`date +%Y%m%d`

for i in `ansible -i /home/ubuntu/operations/ansible/inventory/aws_ec2.yml --list-hosts bsc_web_hosts |grep -v hosts` #all_hosts
  do
    echo -n "${i} "
    ssh -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com "sudo shutdown -r now"
  done
