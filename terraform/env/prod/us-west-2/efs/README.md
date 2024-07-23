# Migration Steps
1. Crate new Terraform folder and deploy EFS 
1. Deploy ansible `ansible-playbook update_generic_w_server.yml -e run_hosts=qa_hosts -e role=migrate_to_efs --diff`
1. Update Cron on W1
```bash

```
1. Manually run the below  

# Automated 
```bash
sudo apt-get -y install nfs-common
mkdir /mnt/env-efs
echo "da-efs.mobilehealthconsumer.com:/ /mnt/env-efs nfs4 defaults,_netdev 0 0" >> /etc/fstab
mount -a
chown mhc:mhc -R /mnt/env-efs
mkdir /mnt/env-efs/benefitsSummaries
mkdir /mnt/env-efs/clientBranding
mkdir /mnt/env-efs/img
mkdir /mnt/env-efs/layoutElementImages
```

# Manual
```bash
sudo su - 
mv -n /home/mhc/mhc-backend/media/benefitsSummaries/* /mnt/env-efs/benefitsSummaries
mv -n /home/mhc/mhc-backend/media/clientBranding/* /mnt/env-efs/clientBranding
mv -n  /home/mhc/mhc-backend/media/img/* /mnt/env-efs/img
mv -n  /home/mhc/mhc-backend/media/layoutElementImages/* /mnt/env-efs/layoutElementImages

mv /home/mhc/mhc-backend/media/benefitsSummaries /home/mhc/mhc-backend/media/benefitsSummaries.old
mv /home/mhc/mhc-backend/media/clientBranding /home/mhc/mhc-backend/media/clientBranding.old
mv /home/mhc/mhc-backend/media/img /home/mhc/mhc-backend/media/img.old
mv /home/mhc/mhc-backend/media/layoutElementImages /home/mhc/mhc-backend/media/layoutElementImages.old

ln -s /mnt/env-efs/benefitsSummaries /home/mhc/mhc-backend/media/benefitsSummaries 
ln -s /mnt/env-efs/clientBranding /home/mhc/mhc-backend/media/clientBranding 
ln -s /mnt/env-efs/img /home/mhc/mhc-backend/media/img 
ln -s /mnt/env-efs/layoutElementImages /home/mhc/mhc-backend/media/layoutElementImages 

chown mhc:mhc -R /mnt/env-efs/benefitsSummaries
chown mhc:mhc -R /mnt/env-efs/clientBranding
chown mhc:mhc -R /mnt/env-efs/img
chown mhc:mhc -R /mnt/env-efs/layoutElementImages

chown mhc:mhc -R /home/mhc/mhc-backend/media/benefitsSummaries
chown mhc:mhc -R /home/mhc/mhc-backend/media/clientBranding
chown mhc:mhc -R /home/mhc/mhc-backend/media/img
chown mhc:mhc -R /home/mhc/mhc-backend/media/layoutElementImages
```