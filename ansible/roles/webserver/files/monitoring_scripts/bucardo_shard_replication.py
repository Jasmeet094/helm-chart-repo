#!/usr/bin/python3

import os, sys
from subprocess import PIPE, run
from datetime import datetime
import time

# This script monitors the state of shard_syncs in an environment. It can be executed on any one shard in the environment as a cron job.
# For every shard in the env it updates a dedicated client record and verifies that the change has been replicated to all the other shards by querying them individually.
# The DB connection settings are scraped from the localsettings.py file
# If a sharddb has a different password it should be added to a .dbpass file in the same directory as this script.
# The format is:
#dbhost:password
# ex: qas04db1pvt.mobilehealthconsumer:dbpassword
#
# The script takes no arguments. Run it only on ONE shard (ex: ps01w1)
# The output of the script is logged in /home/mhc/logs/monitor_shard_syncs.log
#

# logs general messages and errors
def write_log(mesg):
    os.system("echo \"{}\" >> /home/mhc/logs/monitor_shard_syncs.log".format(mesg))


# executes system commands
def exec_cmd(command):
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True)
    return result.stdout


# executes psql commands
def exec_db_cmd(dbhost, query):
    #write_log("Host: {} Query:{} ".format(dbhost, query))
    cmd = 'PGPASSWORD={} psql --host={} --port={} --username={} {} -c "{}"'.format(PASSWORD, dbhost, PORT, USER, DATABASE, query)
    ret = exec_cmd(cmd)
    if not ret:   # possibly didn't connect to the db server. Use an alternative passwd if available
        if dbhost in pws:
            cmd = 'PGPASSWORD={} psql --host={} --port={} --username={} {} -c "{}"'.format(pws[dbhost], dbhost, PORT, USER, DATABASE, query)
            ret = exec_cmd(cmd)
    return ret



write_log("\n===================")
write_log(datetime.now())

# the list of shards in the env are obtained from shard table on the login server. If any of them need to be excluded from monitoring, specify them here.
excl_shards=["ps06"]

# read any alternative db passwords used on some shards
pws = {}
if os.path.isfile("./.dbpass"):
    with open("./.dbpass") as passfile:
        for line in passfile:
            parr = line.split(":")
            if len(parr) != 2:
                continue
            pws[parr[0]] = parr[1].strip()


# scrape all the DB connection related data from the localsettings.py file. Used to run DB sql cmds
HOST=exec_cmd("grep \"'HOST':\" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev")
HOST = HOST.strip()
USER=exec_cmd("grep \"'USER':\" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev")
USER = USER.strip()
PORT=exec_cmd("grep \"'PORT':\" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev")
PORT = PORT.strip()
DATABASE=exec_cmd("grep \"'NAME':\" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev")
DATABASE = DATABASE.strip()
PASSWORD=exec_cmd("grep \"'PASSWORD':\" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev")
PASSWORD = PASSWORD.strip()
LOGIN_DBSERVER=exec_cmd("grep \"LOGIN_SERVER \" /home/mhc/mhc-backend/localsettings.py |  awk '{print $3}' | sed 's/^.https:\/\///' | sed 's/.$//'")
LOGIN_DBSERVER = LOGIN_DBSERVER.replace("w1","db1pvt")
LOGIN_DBSERVER = LOGIN_DBSERVER.strip()

current_shard = HOST.split("db1")[0]

#print("DATABASE:{} HOST:{} USER:{} PORT:{} PW:{} Current Shard:{} LOGIN_DBSERVER:{}".format(DATABASE, HOST, USER, PORT, PASSWORD, current_shard, LOGIN_DBSERVER))


# Get a list of all the shards in the environment by querying the shard table on the login server
query = "select substring(regexp_replace(\\\"adminURL\\\",'w1.mobilehealthconsumer.com',''),9, length(\\\"adminURL\\\")) from partners_shard order by id;"
ret = exec_db_cmd(LOGIN_DBSERVER, query)

shards=[]
for row in ret.split("\n")[2:-3]:
    shards.append(row.strip())

# exclude any shards that are configured but not in use (ex: ps06)
for s in excl_shards:
    if s in shards: shards.remove(s)

# hardcode the list of shards in the env if we were unable to get them from the login server DB
if not shards:
    shards=["ps01", "ps02", "ps03", "ps04", "ps05", "ps07", "ps08", "ps09", "ps10", "ps11", "ps12"]

write_log("Testing shards syncs in {}".format(shards))

# Get the clientid of the client set up for bucardo. The same client can be updated from various shards to test the syncs
query = "select id from partners_client where name ilike 'bucardo (do not delete client)' order by id limit 1"
ret = exec_db_cmd(HOST, query)
bucardo_clientid = ret.split("\n")[2]


# From every shard as the source, update the bucardo client. Then verify that the updated value made it to all the other shards
for src_shard in shards:
    write_log("\nTesting syncs from source shard: {}".format(src_shard))

    src_host = HOST.replace(current_shard, src_shard)

    update_str = "update from: {}  on: {}".format(src_shard, str(datetime.now()))
    query = "update partners_client set \\\"supportText\\\" = '{}' where \\\"isLibrary\\\"='f' and id = {} ".format(update_str, bucardo_clientid)
    ret = exec_db_cmd(src_host, query)

    if "UPDATE 1" not in ret:
        write_log("Could not update client_id:{} on source shard:{} \n".format(bucardo_clientid, src_shard))
        continue

    write_log("Updated client.supportText to:{}".format(update_str))

    # give a sec for the updated record to sync
    time.sleep(1)

    # Verify that the value was updated on all the other shards. If the value is not updated wait for upto 1 min approx before logging the failure
    for dest_shard in shards:
        if dest_shard == src_shard:
            continue
        dest_host = HOST.replace(current_shard, dest_shard)
        write_log("\nVerifying updated data on destination shard: {}".format(dest_shard))
        query = "select id, name, \\\"supportText\\\" from partners_client where id = {} ".format(bucardo_clientid)
        synced = False
        n=1
        while n <= 32:
            ret = exec_db_cmd(dest_host, query)
            if update_str not in str(ret):
                write_log("Sleeping for {} seconds".format(n))
                time.sleep(n)
                n = n*2
            else:
                synced = True
                break

        if not synced:
            write_log(ret)
            write_log("Shard sync failure: {}->{}".format(src_shard, dest_shard))

write_log("===================")