### Adding SSH keys for the MHC user to new servers

Update the users.yml task within the webservers role
Make sure the new users keys are added to the group_vars/all file
Call out to webservers role via the update_generic_w_server.yml
Add the tag for mhcssh to add that users keys

Accomplish this via the authorized_key function within Ansible
Appending ssh key into the authorized_keys file
https://docs.ansible.com/ansible/2.4/authorized_key_module.html

Check to see if it works via this sample command (--check and -diff for testing):
ansible-playbook update_generic_w_server.yml -e run_hosts=p_new_hosts -e role=webserver --tags "mhcssh" --check --diff

(make sure you change update_generic_w_server.yml to use a user that has your local machiens keys on it, for Tom, this would be `remote_user: tom` instead of ubuntu