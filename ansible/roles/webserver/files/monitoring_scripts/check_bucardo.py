#!/usr/bin/python
"""

Usage:
  check_bucardo_delay.py --warning <warning> --critical <critical> --sync_name <sync_name>

Options:
  -h --help           Show this screen.
  --version           Show version.
  --warning           Warning in Seconds
  --critical          Critical in Seconds

Note: This script needs sudo rights to run the bucardo status command

Created by: Matthew Kohn <matt@foghornconsulting.com>
Last Modified: 2021/02/01
Version: 0.2.1
"""

from docopt import docopt
import subprocess
import sys
import datetime
import re


def bash_command(bashCommand):
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output = process.communicate()[0]
    return output

arguments = docopt(__doc__, version='check_bucardo_delay.py 0.2.0')
warning = int(arguments['<warning>'])
critical = int(arguments['<critical>'])
sync_name = arguments['<sync_name>']

output = ""
bucardo_output_for_everything = []
if sync_name == "shard_sync":
    bashCommand = "bucardo status"
    all_bucardo_data = bash_command(bashCommand)
    for line in all_bucardo_data.splitlines():
        result = re.match(r"^ (shard.*sync).*$", line)
        if result and result.group(1):
            bashCommand = "bucardo status %s" % result.group(1)
            bucardo_output_for_everything.append(bash_command(bashCommand))
    if len(bucardo_output_for_everything) == 0:
        print("Ok: No Shard based replication found")
        sys.exit(0)

else:
    bashCommand = "bucardo status %s" % sync_name
    bucardo_output_for_everything.append(bash_command(bashCommand))

difference = 0
shard_difference = 0
now = datetime.datetime.utcnow()
for sync in bucardo_output_for_everything:
    for line in sync.splitlines():
        if "last good" in line.lower():
            end_of_good_line = line.split(":", 1)[1].split("(",1)[0]
            goodline_in_datetime = datetime.datetime.strptime(end_of_good_line, " %b %d, %Y %H:%M:%S ")
            shard_difference = (now - goodline_in_datetime).total_seconds()
            if shard_difference > difference:
                difference = shard_difference
            else:
                pass
            break

if(difference):
    pass
else:
    print("Unknown: It didn't sync")
    sys.exit(3)

performance_data = str("'seconds'=%s;%s;%s;0;0" % (difference, warning, critical))

if difference >= critical:
    print("Critical: The difference between last time sync and now is %s. | %s " % (difference, performance_data))
    sys.exit(2)
elif difference >= warning:
    print("Warning: The difference between last time sync and now is %s. | %s " % (difference, performance_data))
    sys.exit(1)
elif difference <= warning:
    print("Ok: The difference between last time sync and now is %s. | %s " % (difference, performance_data))
    sys.exit(0)
else:
    print("Unknown: The code should not get here")
    sys.exit(3)