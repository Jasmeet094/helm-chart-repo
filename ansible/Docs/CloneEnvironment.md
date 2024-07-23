 I've done this manually a number of times, though I'm not up to speed on the current configurations


 The main places I know of are:

 localsettings.py (about 3 references to hostnames)(also the db address)
 stunnel: the shard object in the DB

 I think there's new stuff, like the IAM role and any cloudwatch stuff that I'm not familiar withThings like the SSO config don't need to be updated for this purpose12:03 PMYep. and all new DNS's created, load balancers (target groups), updating the hostnames.
# Clone environment
# Infra Launch
See HowToLaunchANewEnvironment.md file 
## Automated 
```bash
ansible-playbook cloneenvironment.yml -e run_hosts="pd_hosts" --check
```
Note: this are find and replace so I would recommend spotchecking the files too as I normally find some things that do not work.
## Manual
### POstgres updates
```bash
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
```

#### If prod run this
```bash
UPDATE auth_user SET "email"=NULL;
alter table partners_mhcuser alter column "otherEmail" drop not null;
UPDATE partners_mhcuser SET "otherEmail"=NULL;
alter table partners_mhcuser alter column "androidDeviceToken" drop not null;
UPDATE partners_mhcuser SET "androidDeviceToken"=NULL;
UPDATE partners_mhcuser SET "deviceToken"=NULL;
UPDATE partners_clientreward SET "apiConfig"=NULL; - needs to be done on pclonelogdb1
```