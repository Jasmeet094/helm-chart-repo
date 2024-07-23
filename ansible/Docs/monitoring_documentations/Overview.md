# Overview

This guide provides an overview on how to manage and configure Nagios monitoring service.

## Software

- Nagios runs on SSMON01 server

  - ssmon01 acts as the central monitoring server
  - These configs are not centrally managed in ansible, but this server is continually backed up, so it should be able to be restored with no problem if an issue ever arose

- NRPE agent runs on all the end servers
  - NRPE config is deployed via ansible with the config scatter by design in the the database, web, and nrpe role
  - location `/etc/nagios/nrpe.d`
    - This directory holds all the various nagios plugins that are called as scripts from:
    - `mhc.cfg` is for everyone
    - `database.cfg` is for database servers
    - `web.cfg` is for webservers

## Deployment

- see README.md in the ansible folder for how to deploy updates

## Add a check that runs on central monitoring server

Note: This is for checks the run from the central monitoring server, not on the end servers.

1. ssh to the server at ssmon01pvt.mobilehealthconsumer.com
1. put your script on the server in `/usr/local/nagios/etc/objects/service_check`
1. put your command call to you check in `/usr/local/nagios/etc/objects/service_configs`
   ```bash
       define command{
           command_name    aws_efs
           command_line    /usr/local/nagios/etc/objects/service_check/check_efs.py $HOSTNAME$
       }
   ```
1. if needed, add any devices to the correct locations
   ```bash
   define host{
       use                     generic-elb
       host_name               qaefs01
       address                 qa-efs.mobilehealthconsumer.com
       _instanceregion         us-west-2
       }
   ```
1. if needed, add any hostgroups in `vim /usr/local/nagios/etc/objects/hostgroups.cfg
   ```bash
   define hostgroup{
       hostgroup_name          Q_EFS
       members                 ^q([a-z])efs.*$
   }
   ```
1. add service to the correct location under `/usr/local/nagios/etc/objects/services`
   ```bash
   define service{
       use                             generic-service
       hostgroup_name                  efs
       service_description             AWS: EFS Encryption
       check_command                   aws_efs
   }
   ```
1. check your config with `/usr/local/nagios/bin/nagios -vvv /usr/local/nagios/etc/nagios.cfg`
1. reload service `service nagios reload`
1. validate its all working via the UI
1. setup notifications via `/usr/local/nagios/etc/objects/service_escalations_qa.cfg` or `/usr/local/nagios/etc/objects/service_escalations_prod.cfg`
   ```bash
   define serviceescalation{
           hostgroup_name          nonprod-efs
           service_description     AWS: EFS Encryption
           contact_groups          MHCNonProd
           first_notification      1
           last_notification       0
           notification_interval   60
   }
   ```
1. check your config with `/usr/local/nagios/bin/nagios -vvv /usr/local/nagios/etc/nagios.cfg`
1. reload service `service nagios reload`

## Add a check that runs on remote hosts

Note: This is for checks that run locally on the remote host.

1. Add the script to the correct ansible role

   - database specific checks - `ansible/roles/databases/files/monitoring_scripts/`
   - webserver specific checks - `ansible/roles/webserver/files/monitoring_scripts/`
   - not role specific general checks - `ansible/roles/nrpe/files/`

1. Add to the cfg
   - File location on where to put this
     - if its just for DB the database roles `ansible/roles/databases/templates/monitoring_config/databases.cfg.j2`
     - if is for webservers, then webserver role `operations/ansible/roles/webserver/templates/monitoring_config/webserver.cfg`
     - if everyone then nrpe role `ansible/roles/nrpe/templates/mhc.cfg`
   ```bash
   command[check_oom]=sudo /usr/lib/nagios/plugins/check_oom.sh
   ```
   where
   - `check_oom` is the what you are going to call from the monitoring server
   - `sudo /usr/lib/nagios/plugins/check_oom.sh` is the command it calls
1. run playbooks to push everything

   - These playbooks should be run via the ansible container, [with instructions for configuration here](../../README.md)
   - run_hosts: is the host/group of hosts that it will run against
   - These host/host groups can be found in the [inventory](../../inventory/aws_ec2.yml)

   This example command would run the monitoring part of everything within different playbook against the op_hosts group of hosts.

   ```bash
   ansible-playbook monitoring.yml -e run_hosts=op_hosts -t monitoring --diff
   ```

   This playbooks sole purpose is to trigger the monitoring updates

   - if logging on via your jumpcloud user, you will need to edit and saves this file with your JC username rather than ubuntu, so the correct user is set to connect to the hosts.
     Will accomplish the following:
        - deploy configs for NRPE
        - install requirements for scripts that are put on the servers \* restart services

1. On the monitoring server inself now we need to call that command created above

   ```bash
       vim /usr/local/nagios/etc/objects/services/linuxv2.cfg`

       define service{
       use                     generic-service
       hostgroup_name          linux-servers
       service_description     Linux: OOM Check
       check_command           check_nrpe_1arg!check_oom
   }
   ```

   1. add the check and what is should be checking so in this case where we want it to be on all linux boxes, in

1. check the monitoring server to see if we are good
