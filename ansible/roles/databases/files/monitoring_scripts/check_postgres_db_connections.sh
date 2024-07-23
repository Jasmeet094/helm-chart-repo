#!/bin/bash -e
unset warn crit status code

########################################
## Ensure we always exit
########################################
finish() {
  # Default to unknowns
  output=${output:-"-1"}
  warn=${warn:-"-1"}
  crit=${crit:-"-1"}
  status=${status:-"UNKNOWN"}
  code=${code:-"3"}

  fmt1="%s: Database has %s number of connection"
  fmt2="'Connections'=%s;%s;%s;0;0"

  part1=$(printf "$fmt1" "$status" "$output")
  part2=$(printf "$fmt2" "$output" "$warn" "$crit")

  echo "${part1}|${part2}"
  exit $code
}
trap finish EXIT


########################################
## Read parameters
########################################
usage() {
  echo "usage: $(basename $0)  -w <#> -c <#>"
  echo
  echo "  Required parameters:"
  echo "    -w <#>        Warning threshold (greater than 0)"
  echo "    -c <#>        Critical threshold (greater than warning)"

  trap - EXIT
  exit 4
}

optstring=":w:c:"
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

# Must provide queue name, critcal threshold, and warning threshold
[ -z "$crit" -o -z "$warn" ] && usage

# Warning must be at least a depth of 1
[ $warn -le 0 ] && usage

# Critical must be greater than warnings
[ $crit -le $warn ] && usage


########################################
## Get queue status
########################################
output=$(psql --host=localhost -U bitnami -p 6432 --dbname=djangostack -t -A -c "select count(*) from pg_stat_activity;")


########################################
## Compare status against thresholds
########################################
if [ -z "$output" ]; then
  exit
elif [ $output -ge $crit ]; then
  code=2
  status="CRITICAL"
elif [ $output -ge $warn ]; then
  code=1
  status="WARNING"
else
  code=0
  status="OK"
fi