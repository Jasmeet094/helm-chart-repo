#!/usr/bin/python
# import required libraries
import subprocess
import getpass
import os
import time
import csv
import sys
import pwd
import grp
from pwd import getpwnam


#Initialize Variables and Set Constants
user_should_run_as = "script"
master_server = "172.31.12.188"
master_copy_of_lookup = "lookup_key_files.csv"
local_copy_of_lookup = "/tmp/"
#local_copy_of_lookup = "/Users/matt/Git/clients/Current/MHC/"
profile_of_system_path =  ".system_profile"

# Check the user
running_user = getpass.getuser()

if running_user != user_should_run_as:
    print "ERROR: running as the the wrong user!"
    quit()

# SCP the file from master server to here
subprocess.call(['scp', ':'.join([master_server,master_copy_of_lookup]), local_copy_of_lookup])

#Get hostname of system
try:
    hostname = os.uname()[1]
except Exception as e:
    print "Error when trying to get hostname" % e

#get system profile
try:
    with open(profile_of_system_path) as inputfile:
	system_type = inputfile.readline().rstrip()

except Exception as e:
    print "Error opening file %s " % e

#open the file
local_path_to_file = local_copy_of_lookup + master_copy_of_lookup

with open(local_path_to_file) as inputfile:
    for row in csv.reader(inputfile):
        system = row[0]
        user = row[1]
        key =  row[2]
        if str(system_type) == system:
		file_path = "public_keys/" + key
		subprocess.call(['scp', ':'.join([master_server,file_path]), key])
		subprocess.Popen(['/usr/bin/sudo', '/root/create_authorized_file.py', key, user ])
		time.sleep(1)
	else:
		print "Not correct system"

subprocess.Popen(['/usr/bin/sudo', '/root/move_to_locations.py'])


