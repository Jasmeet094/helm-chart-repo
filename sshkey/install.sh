#!/bin/bash

#Create user
/usr/bin/sudo /usr/sbin/useradd -m -d /home/script -s /bin/bash -c "the script user" -U script --uid 2000

#make folder and put files into it
/usr/bin/sudo /bin/mkdir /home/script/.ssh
/usr/bin/sudo /bin/mv key.pm /home/script/.ssh/id_rsa
/usr/bin/sudo /bin/mv known_hosts /home/script/.ssh

#set permissions
/usr/bin/sudo /bin/chown -R script:script /home/script/.ssh
/usr/bin/sudo /bin/chmod -R 0700 /home/script/.ssh
/usr/bin/sudo /bin/chmod 0600 /home/script/.ssh/id_rsa
/usr/bin/sudo /bin/chmod 0644 /home/script/.ssh/known_hosts

/usr/bin/sudo /bin/mv setup_ssh.py /home/script/setup_ssh.py
/usr/bin/sudo /bin/chmod 775 /home/script/setup_ssh.py

/usr/bin/sudo /bin/mv create_authorized_file.py /root/create_authorized_file.py
/usr/bin/sudo /bin/chown -R root:root /root/create_authorized_file.py
/usr/bin/sudo /bin/chmod -R 0700 /root/create_authorized_file.py

/usr/bin/sudo /bin/mv move_to_locations.py /root/move_to_locations.py
/usr/bin/sudo /bin/chown -R root:root /root/move_to_locations.py
/usr/bin/sudo /bin/chmod -R 0700 /root/move_to_locations.py


(crontab -l -u script 2>/dev/null; echo '0 1 * * * sleep $(expr $RANDOM \% 90); /home/script/setup_ssh.py') | /usr/bin/sudo crontab -u script -


echo '#!/bin/bash' >> ~/sudoers.sh
echo '/usr/bin/sudo echo "script ALL = NOPASSWD:/root/create_authorized_file.py" >> /etc/sudoers' >> ~/sudoers.sh
echo '/usr/bin/sudo echo "script ALL = NOPASSWD:/root/move_to_locations.py" >> /etc/sudoers' >> ~/sudoers.sh

/usr/bin/sudo /bin/bash ~/sudoers.sh
/bin/rm ~/sudoers.sh
