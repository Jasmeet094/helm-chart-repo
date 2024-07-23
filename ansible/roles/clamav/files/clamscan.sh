#!/bin/bash

LOGFILE="/var/log/clamav/clamscan-$(date +'%Y-%m-%d').log";
EMAIL_SUBJECT="ALERT: Malware Found $HOSTNAME";
EMAIL_MSG="Please see the ClamAV log file attached.";
EMAIL_TO="$1";
DIRTOSCAN="$2";

echo "Starting Clamscan"

clamscan -ri --file-list="$DIRTOSCAN" >> "$LOGFILE";

# get the value of "Infected lines"
MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

# if the value is not equal to zero, send an email with the log file attached
if [ "$MALWARE" -ne "0" ];then
echo "Please see attached Clamscan log" | mail -s "$EMAIL_SUBJECT" -A "$LOGFILE" "$EMAIL_TO";
fi 
done

exit 0