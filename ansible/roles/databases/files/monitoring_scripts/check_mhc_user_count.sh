#!/bin/bash -e
unset users warn crit status code

########################################
## Ensure we always exit
########################################
finish() {
  # Default to unknowns
  users=${users:-"unknown"}
  warn=${warn:-"-1"}
  crit=${crit:-"-1"}
  status=${status:-"UNKNOWN"}
  code=${code:-"3"}

  fmt1="%s: table has %s users in it"
  fmt2="'users'=%s;%s;%s;0;0"

  part1=$(printf "$fmt1" "$status" "$users" )
  part2=$(printf "$fmt2" "$users" "$warn" "$crit")

  echo "${part1}|${part2}"
  exit $code
}
trap finish EXIT


########################################
## Read parameters
########################################
usage() {
  echo "usage: $(basename $0) -w <#> -c <#>"
  echo
  echo "  Required parameters:"
  echo "    -w <#>        Warning threshold (greater than 0)"
  echo "    -c <#>        Critical threshold (greater than warning)"

  trap - EXIT
  exit 4
}

optstring="w:c:"
while getopts ${optstring} arg; do
  case ${arg} in
    w) warn="${OPTARG}";;
    c) crit="${OPTARG}";;
    *) usage;;
  esac
done


########################################
## Validation
########################################

# Must provide critcal threshold, and warning threshold
[ -z "$crit" -o -z "$warn" ] && usage

# Warning must be at least a depth of 1
[ $warn -le 0 ] && usage

# Critical must be greater than warnings
[ $crit -le $warn ] && usage


########################################
## Get queue status
########################################
users=$( psql -c 'select count(*) from partners_mhcuser;' -U bitnami -d djangostack  -p 6432  -h localhost -t | head -n 1 | sed 's/^ *//g')


########################################
## Compare status against thresholds
########################################
if [ -z "$users" ]; then
  exit
elif [ $users -ge $crit ]; then
  code=2
  status="CRITICAL"
elif [ $users -ge $warn ]; then
  code=1
  status="WARNING"
else
  code=0
  status="OK"
fi
