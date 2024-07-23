# {{ ansible_managed }}
import sys

server = sys.argv[1]

lines = [line.rstrip('\n') for line in open('keys.txt')]
keys = {}
for line in lines:
    parts = line.split()
    keys[parts[1]] = parts[2]
# print keys

lines = [line.rstrip('\n') for line in open('auth.txt')]
# user = ''
any = False
for line in lines:
    user = 'NotInAuthorizedKeys'
    for key in keys:
        if key in line:
            user = keys[key]
    if 'Accepted' in line:
        any = True
        print('User %s established remote connection to server %s: %s'%(user,server,line))
    else:
        print('Server=%s %s'%(server,line))
if any == False:
    print('No remote access to server % today.'% server)
