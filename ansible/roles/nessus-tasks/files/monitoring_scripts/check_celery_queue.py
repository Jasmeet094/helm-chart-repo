#!/usr/bin/python
import sys
import subprocess
import argparse


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--queue", required=True)
    parser.add_argument("--warning", required=True)
    parser.add_argument("--critical", required=True)

    args = parser.parse_args()

    redis_call = subprocess.Popen('redis-cli llen %s' % args.queue,
                                 shell=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
    response = []
    output = redis_call.stdout.readlines()
    if len(output) != 1:
      print "Unknown: The call to redis should be 1 line not multiple. Ouput was %s" % output
      sys.exit(3)
    for output_item in output:
        try:
          queuelength = int(output_item)
        except TypeError as e:
          print "Could not convert %s to int. Error is %s"  % (queuelength, e)
          sys.exit(3)
    print "OK: The length of the queue is %s|'QueueLength'=%s;%s;%s;0;0" % (queuelength,queuelength,args.warning,args.critical)
    sys.exit(0)
