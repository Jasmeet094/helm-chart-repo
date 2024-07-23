#!/bin/bash

set -euf -o pipefail

#instance=$1
device=$1
instance=`/usr/bin/curl -s "http://169.254.169.254/latest/meta-data/instance-id"`

vol_output=`aws ec2 describe-volumes --region us-west-2 --filters "Name=attachment.instance-id,Values=${instance}" "Name=attachment.device,Values=${device}" \
|jq -r '.Volumes[] | [.VolumeId, .Encrypted, ((.Tags // [])[] |select(.Key=="Name")|.Value)] |@tsv'`

/usr/bin/awk -v dev_name="$device" '
$3 == "" { print "Volume name tag is empty for: " dev_name " Volume may not exist or may not be attached to this host"; exit 1}
$2 == "false" { print "volume: " $1 " is not encrypted"; exit 2}
{ print "Encryption OK for volume: " $1 " named: " $3; exit 0 }' <<<${vol_output}
