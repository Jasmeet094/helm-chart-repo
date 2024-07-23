#!/bin/bash -e
##-------------------------------------------------------------------
## File: check_proc_mem.sh
## Author : Denny
## Description :
## --
##
## Link: http://www.dennyzhang.com/nagois_monitor_process_memory
##
## Created :
## Updated: Time-stamp:
##-------------------------------------------------------------------
SCRIPTNAME=$(basename $0)

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && \
  [ "$3" = "-c" ] && [ "$4" -gt "0" ] && [ -n "$5" ]; then
  COUNTER=1
  TOTALmemVmRSS=0
  TOTALmemVmSize=0
  cmdpattern=$5
  PSOUTPUT=`ps -ef | grep "$cmdpattern" | grep -v grep | grep -v ${SCRIPTNAME}`
  LINECOUNT=`ps -ef | grep "$cmdpattern" | grep -v grep | grep -v ${SCRIPTNAME} | wc -l`
  until [ $COUNTER -ge $LINECOUNT ]; do
    pid=`ps -ef | grep "$cmdpattern" | grep -v grep | grep -v ${SCRIPTNAME} |sed -n "$COUNTER""p" | awk -F' ' '{print $2}'`
    memVmSize=`grep 'VmSize:' /proc/$pid/status | awk -F' ' '{print $2}'`
    memVmSize=$(($memVmSize/1024))
    TOTALmemVmSize=$((memVmSize+$TOTALmemVmSize))

    memVmRSS=`grep 'VmRSS:' /proc/$pid/status | awk -F' ' '{print $2}'`
    memVmRSS=$(($memVmRSS/1024))
    TOTALmemVmRSS=$((memVmRSS+TOTALmemVmSize))

    if [ "$memVmRSS" -ge "$4" ]; then
      echo "Memory: CRITICAL VIRT: PID $pid is using $memVmSize MB - RES: $memVmRSS MB used!|RES=$(($memVmRSS));;;;"
      exit 2
    elif [ "$memVmRSS" -ge "$2" ]; then
      echo "Memory: WARNING VIRT: PID $pid is using $memVmSize MB - RES: $memVmRSS MB used!|RES=$(($memVmRSS));;;;"
      exit 1
    fi
    COUNTER=$((COUNTER+1))
  done
  AVGmemVmRSS=$((TOTALmemVmRSS/$COUNTER))
  echo "Memory: All processes are below threshold; avg memory utilization is for $cmdpattern is $AVGmemVmRSS |RES=$AVGmemVmRSS;;;;"
  $(exit 0)


else
  echo "${SCRIPTNAME}"
  echo ""
  echo "Usage:"
  echo "${SCRIPTNAME} -w -c "
  echo ""
  echo "Below: If tomcat use more than 1024MB resident memory, send warning"
  echo "${SCRIPTNAME} -w 1024 -c 2048 uwsgi"
  echo ""
  exit
fi
## File - check_proc_mem.sh ends

