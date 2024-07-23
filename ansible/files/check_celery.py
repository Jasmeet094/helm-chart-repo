#!/usr/bin/python
import sys
import subprocess
import argparse


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--queues", required=True,  nargs='+')

    args = parser.parse_args()

    #celery_call = subprocess.Popen('sudo su -c "source /home/mhc/mhc-venv/bin/activate;/home/mhc/mhc-backend/manage.py celery inspect active" mhc',
    celery_call = subprocess.Popen('sudo -u mhc bash -c "source /home/mhc/mhc-venv/bin/activate; cd /home/mhc/mhc-backend; celery -A Backend inspect active 2>&1 |grep -v \'^\\[\'"',
                                 shell=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
    response = []
    output = celery_call.stdout.readlines()
    good_queues = []
    bad_queues = []
    for output_item in output:
        for queues in args.queues:
            if "OK" in output_item and "%s:" % queues in output_item:
                good_queues.append(queues)
        else:
            pass
    string_of_good = ", ".join(good_queues)
    counter = len(good_queues)
    if len(args.queues) == len(good_queues):
        print "OK: There are %s number of celery queue running and they are %s. |'Queues'=%s;%s;%s;0;0" % (counter,string_of_good,counter,len(args.queues)-1,len(args.queues)-1)
        sys.exit(0)
    else:
        print "Critical: There are %s number of celery queue running and we current have %s |'Queues'=%s;%s;%s;0;0" % (counter,string_of_good,counter,len(args.queues)-1,len(args.queues)-1)
        sys.exit(2)
