# How to create a whole new ENV (login shards, shards, other infa, etc)

1. Copy a existing folder which matches as closely as possible to requirements inside the `terraform/env/prod/us-west-2/` directory
    * For example, to make another non production ephermeral environment, you would start out copying the `/op` directory to source your terraform code
1. Once you have your new directory, for your new environment, update the backend.tf to be the folder path which matches your new folder
    * For example, If you were created a new om environment (operations matt), you would update this `op` to become `om` to have an updated folder path.
```
    terraform {
  backend "s3" {
    bucket  = "mhc-terraformstate-us-west-2-prod"
    key     = "terraform/env/prod/us-west-2/op"
    region  = "us-west-2"
    profile = "mhc"
  }
}

turns to 

    terraform {
  backend "s3" {
    bucket  = "mhc-terraformstate-us-west-2-prod"
    key     = "terraform/env/prod/us-west-2/om"
    region  = "us-west-2"
    profile = "mhc"
  }
}
``` 

1. Make any changes needed (aka number of shards
    * For new ENVs
        * These shards are configured within the `main.tf` file, and require corresponding configurations to be updated in both the route 53 entries `alb_info` as well as `shard_root`
        * The Records that don't change are the top level env.mobilehealthconsumer.com, and the non numbered dns. You only need to add a env0*.mobilehealthconsumer.com and env0*w*.mobilehealthconsumer per shard that you want to add, so it's a total of 2 new servers per new shard you'd like to increase for your non production environment. 
    * For Cloned ENVs
        * set the follow items:
            * shards_with_new_volumes
            * Amis (update the module to acutally use the amis variable)
            * Update the environment local variable at the top
            * Skim everything to make sure it makes sense
1. Once you have the correct DNS listed for your `alb_info` and corresponding entries in `shard_root` which match your new environment name, you are ready to save your file.
1. Run terraform apply from inside the directory in your environment and wait
    * for example, for the `om` environemnt, run terraform apply from: `/terraform/env/prod/us-west-2/omatt/main`
    * Ensure that you have run terraform init or this will not work
    * Double check to make sure you didn't accidentally copy over the previous terraform statefile into your new folder, and if you did, delete it.
    * !!!!!!!! Make sure that you new environment is creating more than 50 new resources, rather than modifying only something like 6. If you're terraform plan spits out "modify only 6 resources" you've missed something in your prior changes and need to go back and make sure you've updated every entry for environment. 
1. add a group to the `inventory/aws_ec2.yml` file
    ```bash
        om_hosts: "'Name' in (tags|list) and tags.Environment == 'om' "
    ```
1. add to group var who is allowed to ssh into the box otherwise the jenkins ssh key does not get put on the box in `group_vars/all`
    ```bash
    Before (FOR EXAMPLE)
     ssh_users_foghorn_admin:
        allowed_envs:
        - d
        - qa
        - qb
        - op
        - p
        - ot
        allowed_roles:
        - Admin
        - Web
        - Database
        - Nightly
        users:
        - matt
        - tom

        more changes
    
    AFTER (FOR EXAMPLE)
     ssh_users_foghorn_admin:
        allowed_envs:
        - d
        - qa
        - qb
        - op
        - p
        - ot
        - om
        allowed_roles:
        - Admin
        - Web
        - Database
        - Nightly
        users:
        - matt
        - tom
    ```
    * The effect of this script, will be that these users SSH keys will be added to the ubuntu users `authorized_keys` file, so those users can ssh as ubuntu.
1. add instances to TG
1. If you are cloning go back to the cloning document, else continue on below
1. Run ansible from inside the container while on VPN `ansible-playbook application.yml -e run_hosts={{Group}} --diff`
# /ansible/application.yml This step has some irregularities in the applicaiton.yml file with differences between creating a brand new shard vs adding to an existing shard for log servers
1. In order to add more ssh users, go into the MHC jumpcloud admin console, and add your devices to an already existing non production environment, or create a new device group, and associate it with the neccessary user groups to create SSH accounts on the servers.
1. run jenkins, it will fail #it may actually work
1. manually run the rest of the migrations #may not be needed anymore
1. run jenkins again, should succeed #may not be needed anymore
1. DO NOT RUN THIS IN PRODUCTION: BE WARY ON THIS STEP-CAN BREAK EVERYTHIGN: run post ansible-playbook post_jenkins_setup.yml -e run_hosts=op_hosts (play book likely actually called: application_deployment_post_jenkins_setup.yml)
1. setup bucardo on w1 servers once ID is provided by MHC

if Production:
1. Update some files TBD on those files

