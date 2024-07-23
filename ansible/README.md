# How to
## Build the container
1. in the ansible folder run the follow command 
```bash
docker build -t mhcansible:latest .
```
## Running the container
1. add this to your alias file (change it to your paths)
```bash
mhcansible='docker run -it -e AWS_PROFILE=mhc -v /Users/mkohn/.ssh/mhc/MHC-Matt.USWest.pem:/root/.ssh/id_rsa -v /Users/mkohn/.ssh/known_hosts:/root/.ssh/known_hosts:ro -v /Users/mkohn/.aws:/root/.aws -v /Users/mkohn/Documents/Git/mhc/operations:/data --entrypoint /bin/bash mhcansible:latest'
```
1. reload bash and mhcansible

## Update all server
See [Update.md](./Docs/Update.mdUpdate.md)

## Update Nagios configs and deploy changes
See [Deploy a New Monitoring Script Documentation](./Docs/monitoring_documentations/NagiosConfigurationsAndDeployments.md))


## Update nginx on all the hosts
* run_hosts: is the host it will run against
```bash
ansible-playbook update_nginx_hosts.yml -e run_hosts=st_hosts
```
## Updating fonts on hosts
* run_hosts: is the host it will run against
NOTE: You need to run it with the tag option otherwise it will run against everything
```bash
ansible-playbook fonts.yml -e run_hosts=op_hosts -t fonts --diff --check
```

## Adding standard tags to EC2 instances
```bash
ansible-playbook ec2-tagging.yml -e run_hosts=nonprod_hosts --check --diff
```

## Removing Authorized SSH Keys from EC2 Instances
* run_hosts: is the host, or hosts, it will run against
* keyfile: This is a file containing any public keys that should no longer be present on the instance. This must be accessible from where you are executing ansible. Easiest method is to just put it in the ansible folder.
```bash
ansible-playbook purge_ssh_users.yml -e run_hosts=op_hosts -e keyfile=testkeyfile.txt
```
Example: testkeyfile.txt:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjerOSFjfJ7ZGHto3Y5b9RUXr/A0txaR3g6yltz/Yp++sP22SWpI6HQmG2eEc9JMg94YFR9tzfyjLVIBpVEAfHAOAt2/wDOkVY8QrcwkzlJ7frHNZvPPBP2cey567mQq7whsdGCX7mw50AySUM/lXfH8VKP58oKo5J1K+lYRhmVym8pesz+T6zbqNF0iERH2f2kZRu8YmW4Z0RDxvLJvgrDDLiQvf7A6GCapcSRgBCNI6eLlavGTw34QSXTTe19ISbUKcxy5SNVD8AkcjEx3orRhj5WSewT2Hx0z71kk48ReDoDLJnMU2eRiGtSaRS2iCDUjeCZgyhjpeW0s4QC3FR james@foghornconsulting.com
```
## Random Grep commands on all servers
* run_hosts: is the host, or hosts, it will run against
1. open up grep.yml and make changes to shell line

```bash
root@645c15014e09:/data/ansible# ansible-playbook grep.yml -e run_hosts=prod_hosts
```
## Jumpcloud Reset
* run_hosts: is the host, or hosts, it will run against
1. open up grep.yml and make changes to shell line

```bash
ansible-playbook jumpcloud_reset.yml -e run_hosts=op_hosts --diff
```
## HITRUST Ansible tasks

### HiTrust Evidence lines 36 & 40
* run_hosts: is the host it will run against and trigger removals of users over 90 days
```bash
ansible-playbook hitrust_db_evidence.yml -e run_hosts=ps09db1 -e '{dryrun: False}'
```
* This will grab all logs for each DB host and place them in the ansible folder. These can then be copied or screenshotted for HiTrust evidence deliverables.

## Role-based SSH access controls
A recent addition to the Ansible playbook inventory is the ability to control authorized SSH keys on instances via different business functions. This is handled through the `ssh_users` dictionary in the `group_vars/all` file.

SSH users should put their public SSH key in the `all_public_keys` variable located in that file.

Once that key has been added, the user can then be added to a group within the `ssh_users` dictionary. Each group has lists of allowed environments and roles that members of that group are allowed to SSH into.

When the `update_ssh_sftp.yml` playbook is executed, each instance will check the values of it's `Environment` and `Role` tags in EC2. It will then compare that value against the allowed environments and allowed roles for each group of SSH users to find the groups allowed to SSH to that instance and construct a list of users from those groups.

It then loops through that list grabbing each user's public key from the `all_public_keys` variable, if present. If the key is not present, then the user is skipped.

### Updating Authorized keys on instances
The `update_ssh_sftp.yml` playbook is used for updating the authorized keys for the Ubuntu user on instances. It has 2 different methods for execution, controlled by a variable called `overwrite`, which defaults to false.

With overwrite set to false, the playbook will run and apply keys in an additive manner, meaning it will add any keys that should be there but currently are not present, but will not remove any keys that are present but not desired based on the settings in the `ssh_users` dictionary.

To run with overwrite set to false, you can run the command below, updating the run_hosts value to the group of instances you wish to execute the playbook against.
```bash
ansible-playbook update_ssh_sftp.yml -e run_hosts=op_hosts
```

With overwrite set to true, the playbook will construct the list of users per the `ssh_users` group var, and apply them while removing any other keys not in that list.

**Note:** The playbook will skip these tasks if the list of user keys is empty, to prevent removing all authorized keys from the Ubuntu user. This is to prevent accidentally deleting all keys due to a simple typo causing a string mismatch.

To run with overwrite set to true, you can run the command below, updating the run_hosts value to the group of instances you wish to execute the playbook against.
```bash
ansible-playbook update_ssh_sftp.yml -e run_hosts=op_hosts -e overwrite=true
```
