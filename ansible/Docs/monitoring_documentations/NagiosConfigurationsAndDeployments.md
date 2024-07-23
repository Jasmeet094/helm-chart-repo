# Updating configuration and deployment

## Update NRPE on all the hosts

- These playbooks should be run via the ansible container, [with instructions for configuration here](../../README.md)
- run_hosts: is the host/group of hosts that it will run against
- These host/host groups can be found in the [inventory](../../inventory/aws_ec2.yml)

This example command would run the nrpe.yml playbook against the op_hosts group of hosts.

```bash
ansible-playbook nrpe.yml -e run_hosts=op_hosts
```

This playbooks sole purpose is to trigger the nrpe role. And set what remote user you intend to use.

- if logging on via your jumpcloud user, you will need to edit and saves this file with your JC username rather than ubuntu, so the correct user is set to connect to the hosts.
- the result of this role is running the [monitoring.yml](../../roles/nrpe/tasks/monitoring.yml) which should update NRPE on all the servers.
- ToDo: Find out if/when "--tags monitoring" is needed for this to update NRPE on all the hosts

## Update NRPE config on all the hosts

- run_hosts: is the host it will run against
  NOTE: You need to run it with the tag option otherwise it will run against everything

So running:

```bash
ansible-playbook monitoring.yml -e run_hosts=op_hosts --tags monitoring --diff
```

Will accomplish the following:

- Update the contents of the mhc.cfg file to match your local file in the repository
- Ensure plugins are installed for linux stats
- Ensure pymongo is installed
- Copy check linux stats file onto the server
- restart the service `nagio-nrpe-server` when triggered

## Deploying new monitoring scripts

In order to add new monitoring scripts to the nagios server, follow these next steps

1. Create you script, nagios plugin, command, etc. for deployment
1. Store script as it's own file inside the [nrpe role files directory](../../roles/nrpe/files/)
1. Create command which calles that script in [mhc.cfg](../../roles/nrpe/templates/mhc.cfg) for example: `command[check_clamfresh]=/usr/lib/nagios/plugins/check_procs -c 1:1 -C freshclam`
1. Run the deploy script: Here:
