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
Last Modified: 2017/1/23
Version: 0.1.0
"""
from docopt import docopt
import subprocess
import sys
import os
import datetime

arguments = docopt(__doc__, version='check_bucardo_delay.py 0.1.0')
warning = int(arguments['<warning>'])
critical = int(arguments['<critical>'])
sync_name = arguments['<sync_name>']

output = ""
bashCommand = "bucardo status %s" % sync_name
process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
output = process.communicate()[0]

#get the data
if "" == output:
    print "Unknown: Could not get data from bucardo"
    sys.exit(3)
else:
    now = datetime.datetime.utcnow()
    for line in output.splitlines():
        if "last good" in line.lower():
            end_of_good_line = line.split(":", 1)[1].split("(",1)[0]
            goodline_in_datetime = datetime.datetime.strptime(end_of_good_line, " %b %d, %Y %H:%M:%S ")
            difference = (now - goodline_in_datetime).total_seconds()
            break

performance_data = str("'seconds'=%s;%s;%s;0;0" % (difference, warning, critical))

if difference >= critical:
    print "Critical: The difference between last time sync and now is %s. | %s " % (difference, performance_data)
    sys.exit(2)
elif difference >= warning:
    print "Warning: The difference between last time sync and now is %s. | %s " % (difference, performance_data)
    sys.exit(1)
elif difference <= warning:
    print "Ok: The difference between last time sync and now is %s. | %s " % (difference, performance_data)
    sys.exit(0)
else:
    print "Unknown: The code should not get here"
    sys.exit(3)
