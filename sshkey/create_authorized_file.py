#!/usr/bin/python


#####
##
## This file should be in /root
##
#####


import sys
import os

#stores arguments
file_name=sys.argv[1]
on_system_user=sys.argv[2]

print  on_system_user
#predefined variables
path_of_output = "/root/keys"
path_of_input = "/home/script"

#checks to see if path exist and if not creates it
if(not(os.path.isdir(path_of_output))):
	os.mkdir(path_of_output)

#opens the files it requires
key_file = open('%s/%s' % (path_of_input, file_name), 'r')
output_file = open('%s/%s' % (path_of_output, on_system_user), 'a')

#Writes to 1 file
output_file.write(key_file.read())

#removes and cleans up unneeded files
os.remove('%s/%s' % (path_of_input, file_name))
key_file.close()
output_file.close()
