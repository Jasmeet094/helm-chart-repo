#!/bin/bash -e
unset queue depth warn crit status code

########################################
## Ensure we always exit
########################################
finish() {
  # Default to unknowns
  queue=${queue:-"unknown"}
  depth=${depth:-"-1"}
  warn=${warn:-"-1"}
  crit=${crit:-"-1"}
  status=${status:-"UNKNOWN"}
  code=${code:-"3"}

  fmt1="%s: %s has %s number of messages in the queue"
  fmt2="'Messages'=%s;%s;%s;0;0"

  part1=$(printf "$fmt1" "$status" "$queue" "$depth")
  part2=$(printf "$fmt2" "$depth" "$warn" "$crit")

  echo "${part1}|${part2}"
  exit $code
}
trap finish EXIT


########################################
## Read parameters
########################################
usage() {
  echo "usage: $(basename $0) -q <queue> -w <#> -c <#>"
  echo
  echo "  Required parameters:"
  echo "    -q <queue>    Name of the queue"
  echo "    -w <#>        Warning threshold (greater than 0)"
  echo "    -c <#>        Critical threshold (greater than warning)"

  trap - EXIT
  exit 4
}

optstring=":q:w:c:"
while getopts ${optstring} arg; do
  case ${arg} in
    w) warn="${OPTARG}";;
    c) crit="${OPTARG}";;
    q) queue="${OPTARG}";;
    *) usage;;
  esac
done


########################################
## Validation
########################################

# Must provide queue name, critcal threshold, and warning threshold
[ -z "$queue" -o -z "$crit" -o -z "$warn" ] && usage

# Warning must be at least a depth of 1
[ $warn -le 0 ] && usage

# Critical must be greater than warnings
[ $crit -le $warn ] && usage


########################################
## Get queue status
########################################
output=$(sudo rabbitmqctl list_queues)
depth=$(echo "$output" | awk -v queue="$queue" 'queue == $1 {print $2}')


########################################
## Compare status against thresholds
########################################
if [ -z "$depth" ]; then
  exit
elif [ $depth -ge $crit ]; then
  code=2
  status="CRITICAL"
elif [ $depth -ge $warn ]; then
  code=1
  status="WARNING"
else
  code=0
  status="OK"
fi
