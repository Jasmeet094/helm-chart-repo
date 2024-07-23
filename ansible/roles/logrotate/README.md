# Ansible Role: logrotate

## Description

This Ansible role installs and configures the [Amazon CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html) on Ubuntu EC2 instances. The CloudWatch Agent collects logs and metric data from EC2 instances and sends them to Amazon CloudWatch to store and view.

## Usage

Run this role by calling the `update_cloudwatch.yml` playbook and passing the `run_hosts` and `user` vars.

```bash
ansible-playbook update_cloudwatch.yml -e run_hosts={{ HOSTS }} -e user={{ USER }}
```

## Agent Config Cleanup

We discovered some CloudWatch Agent config drift across servers. In an attempt to lessen config sprawl and start fresh, the Ansible role first checks to see if particular config files exist. If they do, Ansible will delete the config files and write new ones.

## Changelog
- Checks apt database if the `CloudWatch Agent` is already installed. If it's not, downloads and installs the agent.
- Adds a handler to run the cloudwatch agent control script to configure/reconfigure the agent whenever necessary.
- Removes `/etc/awslogs` completely.
- Updates to agent config:
  - Puts the agent config in the correct directory.
  - Adds advanced metrics to the agent config.
  - Updates `timestamp_format` for logs with consistent timestamps.
  - Adds `multi_line_start_pattern` for log events than span multiple lines in a log file.
