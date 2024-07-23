 I've done this manually a number of times, though I'm not up to speed on the current configurations


 The main places I know of are:

 localsettings.py (about 3 references to hostnames)(also the db address)
 stunnel: the shard object in the DB

 I think there's new stuff, like the IAM role and any cloudwatch stuff that I'm not familiar withThings like the SSO config don't need to be updated for this purpose12:03 PMYep. and all new DNS's created, load balancers (target groups), updating the hostnames.


# Web
sed -i "s/qa/qn/g" /home/mhc/mhc-backend/localsettings.py
sed -i "s/qa/qn/g" /etc/stunnel/mhc.conf 
sed -i "s/qa/qn/g" /etc/bucardorc
sed -i "s/qa/qn/g" /home/mhc/bin/sync_script.sh


# All Servers
hostname {hostname}
sed -i "s/qa/qn/g" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml
sed -i "s/qa/qn/g" /opt/aws/amazon-cloudwatch-agent/etc/log-config.json
sed -i "s/qa/qn/g" /etc/awslogs/awslogs.conf
sed -i "s/qa/qn/g" /etc/machine-info
sed -i "s/preserve_hostname: false/preserve_hostname: true/g" /etc/cloud/cloud.cfg


# As Bucardo
bucardo update db login dbname=djangostack host=qnlogdb1pvt.mobilehealthconsumer.com port=6432 pass=xxx
bucardo update db shard_4 dbname=djangostack host=qns04db1pvt.mobilehealthconsumer.com port=6432 pass=xxxxx


UPDATE partners_shard
SET ("baseURL", "adminURL") = ('https://qns03.mobilehealthconsumer.com', 'https://qns03.mobilehealthconsumer.com')
WHERE id = 3;

select * from partners_shard;
UPDATE partners_shard
SET ("baseURL", "adminURL") = ('https://qns01.mobilehealthconsumer.com', 'https://qns01.mobilehealthconsumer.com')
WHERE id = 1;
UPDATE partners_shard
SET ("baseURL", "adminURL") = ('https://qns02.mobilehealthconsumer.com', 'https://qns02.mobilehealthconsumer.com')
WHERE id = 2;
UPDATE partners_shard
SET ("baseURL", "adminURL") = ('https://qns03.mobilehealthconsumer.com', 'https://qns02.mobilehealthconsumer.com')
WHERE id = 3;

    2 | Shard 2 | https://qns02.mobilehealthconsumer.com | https://qns02.mobilehealthconsumer.com | 10000000000 | SI6A2dw4lZ0KtwQdoA1SAg9MXbSaiefNeAFcw7ZKDI4=
    3 | Shard 3 | https://qns03.mobilehealthconsumer.com | https://qas03w1.mobilehealthconsumer.com | 20000000000 | KeXEv3Do5Mqprwxn6OcWtMWQe7pXM0S/UaMBPyMmLqc=
    1 | Shard 1 | https://qns01.mobilehealthconsumer.com | https://qas01w1.mobilehealthconsumer.com |           0 | ua2hpXipzYXpas8xtfnHnN8BhQwmtF6xe2wfSv3f0Mg=
    4 | Shard 4 | https://qns04.mobhealthinternal.com    | https://qas04w1.mobilehealthconsumer.com | 30000000000 | dv2Y/LFWewjNBXssiZ0kBozCIKWc01TOxitM3Jtp94U=
    
###########
- replace:
path: /home/mhc/mhc-backend/localsettings.py
regexp: '(\s+)old\.host\.name(\s+.*)?$'
replace: '\1new.host.name\2'
backup: yes