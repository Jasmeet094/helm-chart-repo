## Steps

1. Terraform, (update state file with letter of the environment)
1. create a new group within the arrtifory files (ansi)
1. ansible, (ansible-playbook application.yml -e run_hosts=qa_s05_hosts)
1. jenkins deploy, https://jenkins.mobilehealthconsumer.com/job/MHCDeploy/ Update the choice list for this job under config and add the hostnames (a: tells it its an admin server)
1. post jenkins ansible playbook, 
1. terrafrom alb, 
1. maybe some manual cleanup with Tags (for backups), DNS, extra instances.