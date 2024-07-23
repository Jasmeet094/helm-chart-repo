# Monthly Patching
## Log Location
s3://mhc-logs/os_updates/{{run_hosts}}/

## Setup
1. Git pull repo to ensure you have the latest code. 
1. Check to see what servers are in the run_hosts list you are going to do
    ```bash
    root@ba374c537eec:/data/ansible# ansible-inventory nonprod_hosts --graph
    @op_hosts:
      |--oplogdb1
      |--oplogw1
      |--oplogw2
      |--ops01db1
      |--ops01w1
      |--ops01w2
    ```
1. Preform Cache update

    This will do the follow: 
    * apt-get update
    * Upload Logs to S3
    ```bash
ansible-playbook apt_update_all.yml -e run_hosts=ss_hosts -e user=mkohn
ansible-playbook apt_update_all.yml -e run_hosts=nonprod_hosts -e user=mkohn
ansible-playbook apt_update_all.yml -e run_hosts=prod_hosts -e user=mkohn
    
    PLAY RECAP     ***********************************************************************************************************************************************************************************************************************************
    oplogdb1                   : ok=8    changed=6    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
    oplogw1                    : ok=7    changed=6    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
    oplogw2                    : ok=7    changed=6    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
    ops01db1                   : ok=7    changed=6    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
    ops01w1                    : ok=7    changed=6    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
    ops01w2                    : ok=7    changed=6    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
    
    Wednesday 06 January 2021  15:13:16 +0000 (0:00:00.259)       0:00:50.459 *****
    ===============================================================================
    patching : Plan write log ----------------------------------------------------------------- 9.80s
    patching : Update apt cache --------------------------------------------------------------- 9.55s
    Gathering Facts --------------------------------------------------------------------------- 7.90s
    patching : Simulate apt upgrade ----------------------------------------------------------- 5.92s
    patching : Fetch Plan write log ----------------------------------------------------------- 5.07s
    pause ------------------------------------------------------------------------------------- 5.05s
    patching : Ship Plan write log to S3 ------------------------------------------------------ 3.07s
    patching : Cleanup Plan write log --------------------------------------------------------- 0.87s
    Run patching role ------------------------------------------------------------------------- 0.58s
    patching : Ship Apply write log to S3 ----------------------------------------------------- 0.43s
    patching : Cleanup Apply write log -------------------------------------------------------- 0.35s
    patching : Apply write log ---------------------------------------------------------------- 0.28s
    patching : Fetch Apply write log ---------------------------------------------------------- 0.28s
    debug ------------------------------------------------------------------------------------- 0.26s
    Run service restart role on Apply Upgrades ------------------------------------------------ 0.26s
    patching : Log the upgrade results -------------------------------------------------------- 0.25s
    patching : Apply apt upgrade -------------------------------------------------------------- 0.24s
    patching : Basic AMI Creation and waiting async# ------------------------------------------ 0.23s
    root@ba374c537eec:/data/ansible#
    ```

1. Preform actual update

    This will do the follow: 
    * take AMI
    * apt-get upgrade
    * Reboot Boxes
    * Stop all servers
    * Start Services in the right order
    ```bash
    ansible-playbook apt_update_all.yml  -e run_hosts=nonprod_hosts -e apply_upgrade=True -e restart_hosts=True -e user=mkohn
    
    PLAY RECAP     ***********************************************************************************************************************************************************************************************************************************
    oplogdb1                   : ok=17   changed=13   unreachable=0    failed=0    skipped=20   rescued=0    ignored=0
    oplogw1                    : ok=24   changed=21   unreachable=0    failed=0    skipped=12   rescued=0    ignored=0
    oplogw2                    : ok=24   changed=21   unreachable=0    failed=0    skipped=12   rescued=0    ignored=0
    ops01db1                   : ok=16   changed=13   unreachable=0    failed=0    skipped=20   rescued=0    ignored=0
    ops01w1                    : ok=26   changed=23   unreachable=0    failed=0    skipped=10   rescued=0    ignored=0
    ops01w2                    : ok=24   changed=21   unreachable=0    failed=0    skipped=12   rescued=0    ignored=0
    
    Wednesday 06 January 2021  15:26:19 +0000 (0:00:03.115)       0:04:40.408 *****
    ===============================================================================
    restart_OS_restart_services : Reboot a slow machine that might have lots of updates to apply --------------------- 131.56s
    patching : Apply apt upgrade -------------------------------------------------------------------------------------- 11.77s
    Gathering Facts --------------------------------------------------------------------------------------------------- 10.08s
    restart_OS_restart_services : ensure celerybglowbandwidth is stop -------------------------------------------------- 7.13s
    patching : Basic AMI Creation and waiting async# ------------------------------------------------------------------- 6.82s
    patching : Apply write log ----------------------------------------------------------------------------------------- 6.70s
    restart_OS_restart_services : ensure rabbitmq-server is started ---------------------------------------------------- 6.38s
    restart_OS_restart_services : ensure celeryhr is stop -------------------------------------------------------------- 6.12s
    restart_OS_restart_services : ensure rabbitmq-server is stop ------------------------------------------------------- 6.11s
    restart_OS_restart_services : ensure celery is stop ---------------------------------------------------------------- 5.86s
    restart_OS_restart_services : ensure celerybg is stop -------------------------------------------------------------- 5.83s
    patching : Fetch Apply write log ----------------------------------------------------------------------------------- 5.24s
    restart_OS_restart_services : Start postgresql --------------------------------------------------------------------- 5.19s
    restart_OS_restart_services : ensure mhc is stop ------------------------------------------------------------------- 5.15s
    pause -------------------------------------------------------------------------------------------------------------- 5.07s
    restart_OS_restart_services : started stunnel4 --------------------------------------------------------------------- 5.01s
    restart_OS_restart_services : ensure celerybg is started ----------------------------------------------------------- 4.76s
    restart_OS_restart_services : Stop stunnel4 ------------------------------------------------------------------------ 4.60s
    restart_OS_restart_services : Stop postgresql ---------------------------------------------------------------------- 4.43s
    restart_OS_restart_services : ensure celery is started ------------------------------------------------------------- 4.24s
    root@ba374c537eec:/data/ansible#
    root@ba374c537eec:/data/ansible#
    ```
