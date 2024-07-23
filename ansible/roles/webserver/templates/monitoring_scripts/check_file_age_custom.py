#!/usr/bin/python
import subprocess
import sys

try:
    output = ""
    file = "/home/mhc/send_mail.lock"
    bashCommand = "/usr/lib/nagios/plugins/check_file_age -f %s -w {{ nrpe_warning_file_age }} -c {{ nrpe_critical_file_age }}" % file
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output = process.communicate()[0]
    returncode = process.returncode
    if returncode == 2 and "File not found" in output:
        print "OK: File %s not found" % file
        sys.exit(0)
    else:
        print output
        sys.exit(returncode)
except Exception as e:
    print "Unknown: There is an unknown issue in the script. %s" % e
    sys.exit(3)
