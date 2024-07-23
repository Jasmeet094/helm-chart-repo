#! /bin/bash
# {{ ansible_managed }}
pushd .
cd /root/bin/

# copy the auth.log to the local directory and make it readable:
sudo cp /var/log/auth.log .
sudo chown ubuntu:ubuntu auth.log

# Pick up relevant lines from auth.log:
grep -B 1 "Accepted publickey for" auth.log > auth.txt
grep "sudo:" auth.log | grep "COMMAND" >> auth.txt

# Copy the authorized keys to the local directory an convert to fingerprints:
cp /home/ubuntu/.ssh/authorized_keys .
cat /home/*/.ssh/authorized_keys >> authorized_keys
split -l 1 authorized_keys authorized_keys
rm authorized_keys
for i in authorized_keys*; do
   ssh-keygen -lf $i >>keys.txt
done

# Combine the keys and relvant lines to make the daily remote access log:
python remote-connection-log.py {{ inventory_hostname_short }}pvt >remote-access-log-$(date +"%Y%m%d").txt

# Matt puts some code here to make Redmine ticket and attach file remote-access-log-$(date +"%Y%m%d").txt
#/var/awslogs/bin/aws sns publish --topic-arn {{ authentication_sns_topic }}  --message "`cat remote-access-log-$(date +"%Y%m%d").txt`" --region us-west-2 --subject "{{ inventory_hostname_short }}pvt Auth Log"

# Clean up:
rm auth.log
rm authorized_keys*
rm auth.txt
rm keys.txt
#remote-access-log-$(date +"%Y%m%d").txt

popd
