#!/bin/bash
LOCATION1="/Users/matt/Git/cm/mhc/sshkey"
LOCATION2="/Users/matt/scratch/"
KEY="/Users/matt/ssh/clients/mhc/MHC-Matt.USWest.pem"

for INSTANCE in "172.31.12.188" "172.31.8.138"
do
	echo "Instance is: " $INSTANCE
	scp -i $KEY $LOCATION2/key.pm ubuntu@$INSTANCE:~/
	scp -i $KEY $LOCATION2/known_hosts ubuntu@$INSTANCE:~/
    scp -i $KEY $LOCATION1/setup_ssh.py ubuntu@$INSTANCE:~/
	scp -i $KEY $LOCATION1/install.sh ubuntu@$INSTANCE:~/
	scp -i $KEY $LOCATION1/move_to_locations.py ubuntu@$INSTANCE:~/
    scp -i $KEY $LOCATION1/create_authorized_file.py ubuntu@$INSTANCE:~/
	
	ssh -t -i $KEY -l ubuntu $INSTANCE "bash install.sh"

done
