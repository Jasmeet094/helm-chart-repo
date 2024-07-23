#!/bin/bash

set -uo pipefail

#file_date=`date +%Y%m%d`

for i in `ansible -i /home/ubuntu/operations/ansible/inventory/aws_ec2.yml --list-hosts qa_hosts |grep -v hosts` #all_hosts
  do
    echo -n "${i} "
    #ssh -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com "sudo ps -ef |grep -i uwsgi |wc -l"
    #ssh -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com "cat /etc/systemd/system/mhc.service |grep Kill"
    ssh -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com "sudo free |grep -i swap"
    #ssh -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com "sudo rm /tmp/remote-access-log-${file_date}.txt"
  done
