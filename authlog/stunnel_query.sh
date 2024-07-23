#!/bin/bash

for i in `ansible -i /home/ubuntu/operations/ansible/inventory/aws_ec2.yml --list-hosts all_hosts |grep -v hosts`
  do
    echo -n  $i.mobhealthinternal.com
    ssh -i /home/ubuntu/.ssh/ansible.key ubuntu@$i.mobhealthinternal.com "sudo dpkg --list |grep -i stunnel"
  done
