#!/usr/bin/python


#######
##
## This file should be in root
##
#######
# import required libraries
import subprocess
import getpass
import os
import csv
import sys
import pwd
import grp
#from pwd import getpwnam
from os import listdir
from os.path import isfile, join
import shutil



mypath = "/root/keys/"


onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]

for file in onlyfiles:

    file_path = mypath + file
    user = file
    uid = pwd.getpwnam(user).pw_uid
    gid = grp.getgrnam(user).gr_gid

    #checks to make sure user exist
    try:
        pwd.getpwnam(user)
    except KeyError:
        print('User %s does not exist.' % user)
        quit()

    #checks to make sure group exist
    try:
        grp.getgrnam(user)
    except KeyError:
        print('Group %s does not exist.' % user)
        quit()

    try:
		user_homedir = os.path.expanduser('~%s'%user)
    except:
		print "User does not exist on the system"
		quit()

    user_sshdir = user_homedir + "/.ssh"

    #checks is folder does exist, if it does not exist it creates the path
    if not(os.path.exists(user_homedir)):
        print "Error: User does not have a home folder"
        quit()
    if not(os.path.exists(user_sshdir)):
        try:
		os.mkdir(user_sshdir)
		os.chmod(user_sshdir,0700)
		os.chown(user_sshdir,uid,gid)
	except Exception as e:
            print "Error: %s" % e
            quit()

    #copy Keys
    ssh_key_path = user_sshdir + "/authorizied_keys"
    shutil.copy2(file_path, ssh_key_path)

    #Set premissions
    os.chmod(ssh_key_path,0644)
    os.chown(ssh_key_path,uid,gid)

    os.remove(file_path)
