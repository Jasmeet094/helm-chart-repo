
# Setup of rsycn between servers
```bash 
Append the id_rsa.pub file to all the same shard w2..wN server instances /home/mhc/.ssh/authorized_keys files
Test ssh connects from mhc@ps??w1 to mhc@ps??wN 
On the W1 server, edit /home/mhc/bin/syncscript so that it copies the right directories from/to all teh same shard w2..wn server instances
  425  vi sync_script.sh
  426  chown mhc:mhc sync_script.sh
  427  chmod +x sync_script.sh
  428  ls
  429  sudo su - mhc
  261  ssh-keygen
  262  cat .ssh/id_rsa.pub
  263  ssh sts01w2pvt.mobilehealthconsumer.com
  (mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ mkdir benefitsSummaries
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ mkdir clientBranding
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ mkdir export_schedules
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ mkdir IDCards
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ mkdir img
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ mkdir reimbursement
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ ls benefitsSummaries/
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ ls benefitsSummaries/
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ ln -s reimbursement/ r
(mhc-venv3) mhc@sts01w2pvt:~/mhc-backend/media$ ls -lah
```