#!/bin/bash
ID=$1
echo "`date -u`"
echo "Runnning update on MHC user for ID $ID"
USER=`grep "'USER':" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev`
PASSWORD=`grep "'PASSWORD':" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev`
HOST=`grep "'HOST':" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev`
PORT=`grep "'PORT':" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev`
DATABASE=`grep "'NAME':" /home/mhc/mhc-backend/localsettings.py |  awk '{print $2}' | cut -c 2- | rev | cut -c 3- | rev`
export PGPASSWORD=$PASSWORD

if  [ -e /var/tmp/bucardo_sync.sql ]
then
  rm /var/tmp/bucardo_sync.sql
fi
echo '\connect djangostack;' >> /var/tmp/bucardo_sync.sql
echo "update partners_mhcuser" >> /var/tmp/bucardo_sync.sql
echo "    set address2 = now()" >> /var/tmp/bucardo_sync.sql
echo "    where \"employeeID\" = 'bucardo'" >> /var/tmp/bucardo_sync.sql
echo "      and id=$ID ;" >> /var/tmp/bucardo_sync.sql

psql --host=$HOST --port=$PORT --username=$USER $DATABASE -f /var/tmp/bucardo_sync.sql

rm /var/tmp/bucardo_sync.sql
