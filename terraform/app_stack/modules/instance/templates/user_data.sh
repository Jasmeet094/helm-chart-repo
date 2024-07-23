#!/bin/bash

# install aws cli
# download ebsvnme-id from s3
# update udev rules
# reboot server

/usr/bin/apt-get update --assume-yes
/usr/bin/apt-get install --assume-yes awscli
/usr/bin/aws s3 cp s3://mhc-secure/ebsnvme-id /usr/local/bin
/bin/chmod 755 /usr/local/bin/ebsnvme-id
/bin/echo 'KERNEL=="nvme[0-9]*n[0-9]*", ENV{DEVTYPE}=="disk", ATTRS{model}=="Amazon Elastic Block Store", PROGRAM="/usr/local/bin/ebsnvme-id -u /dev/%k", SYMLINK+="%c"' >/etc/udev/rules.d/71-ec2-nvme-devices.rules
/sbin/reboot
