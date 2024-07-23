provider "aws" {
  region  = "us-west-2"
  profile = "mhc"
}

resource "aws_iam_role" "mhc_backups" {
  name               = "mhc_aws_backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
 ]
}
POLICY
}

module "aws_mhc_backup_prod" {
  source             = "../../../../modules/AWS_backup"
  client             = "mhc"
  env                = "prod"
  kms_primary_key    = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  kms_dr_key         = "arn:aws:kms:us-east-1:913835907225:key/b26c62b3-65de-4145-aa8e-d00b60e09584"
  backup_role_name   = aws_iam_role.mhc_backups.name
  backup_role_arn    = aws_iam_role.mhc_backups.arn
  dr_backups         = true
  dr_region          = "us-east-1"
  aws_backup_tag_key = "mhc-prod-backup"
  type               = "EBS-"
  rules = [
    {
      name              = "mhc-prod-daily-EBS-rule"
      schedule          = "cron(0 05 * * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 360
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 30
      },
      copy_action = {
        lifecycle = {
          cold_storage_after = 0
          delete_after       = 10
        },
        destination_vault_arn = ""
      }
    },
    {
      name              = "mhc-prod-weekly-EBS-rule"
      schedule          = "cron(0 05 ? * SUN *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 360
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 90
      }
    },
    {
      name              = "mhc-prod-monthly-EBS-rule"
      schedule          = "cron(0 05 1 * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 360
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 2556
      }
    },
  ]
}

module "aws_anthem_backup_prod" {
  source          = "../../../../modules/AWS_backup"
  client          = "anthem"
  env             = "prod"
  kms_primary_key = "arn:aws:kms:us-west-2:950511364051:key/7cd90a34-4ddd-40cb-8691-4bde9cd530e5"
  kms_dr_key      = "arn:aws:kms:us-east-1:950511364051:key/2ae17b1f-2428-42d4-89da-60bee75dee89"
  # kms_primary_key    = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712" #AWS_MobileHealthConsumer_Prod_2020
  # kms_dr_key         = "arn:aws:kms:us-east-1:950511364051:key/1e8939f7-176f-4119-a505-315603ce2cad" #AWS_MobileHealthConsumer_DR_2020
  backup_role_name   = aws_iam_role.mhc_backups.name
  backup_role_arn    = aws_iam_role.mhc_backups.arn
  dr_backups         = true
  dr_region          = "us-east-1"
  aws_backup_tag_key = "anthem-prod-backup-2019"
  type               = "EBS-"
  rules = [
    {
      name              = "anthem-prod-daily-EBS-rule"
      schedule          = "cron(0 07 * * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 30
      },
      copy_action = {
        lifecycle = {
          cold_storage_after = 0
          delete_after       = 10
        },
        destination_vault_arn = ""
      }
    },
    {
      name              = "anthem-prod-weekly-EBS-rule"
      schedule          = "cron(0 08 ? * SUN *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 90
      }
    },
    {
      name              = "anthem-prod-monthly-EBS-rule"
      schedule          = "cron(0 09 1 * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 2556
      }
    },
  ]
}

module "aws_anthem_backup_prod_2020" {
  source = "../../../../modules/AWS_backup"
  client = "anthem"
  env    = "prod"
  # kms_primary_key    = "arn:aws:kms:us-west-2:950511364051:key/7cd90a34-4ddd-40cb-8691-4bde9cd530e5"
  # kms_dr_key         = "arn:aws:kms:us-east-1:950511364051:key/2ae17b1f-2428-42d4-89da-60bee75dee89"
  kms_primary_key    = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712" #AWS_MobileHealthConsumer_Prod_2020
  kms_dr_key         = "arn:aws:kms:us-east-1:950511364051:key/1e8939f7-176f-4119-a505-315603ce2cad" #AWS_MobileHealthConsumer_DR_2020
  backup_role_name   = aws_iam_role.mhc_backups.name
  backup_role_arn    = aws_iam_role.mhc_backups.arn
  dr_backups         = true
  dr_region          = "us-east-1"
  aws_backup_tag_key = "anthem-prod-backup"
  year               = "2020"
  type               = "EBS-"
  rules = [
    {
      name              = "anthem-prod-daily-EBS-rule"
      schedule          = "cron(0 07 * * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 30
      },
      copy_action = {
        lifecycle = {
          cold_storage_after = 0
          delete_after       = 10
        },
        destination_vault_arn = ""
      }
    },
    {
      name              = "anthem-prod-weekly-EBS-rule"
      schedule          = "cron(0 08 ? * SUN *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 90
      }
    },
    {
      name              = "anthem-prod-monthly-EBS-rule"
      schedule          = "cron(0 09 1 * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 2556
      }
    },
  ]
}

module "aws_mhc_backup_nonprod" {
  source             = "../../../../modules/AWS_backup"
  client             = "mhc"
  env                = "nonprod"
  kms_primary_key    = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  kms_dr_key         = "arn:aws:kms:us-east-1:913835907225:key/b26c62b3-65de-4145-aa8e-d00b60e09584"
  backup_role_name   = aws_iam_role.mhc_backups.name
  backup_role_arn    = aws_iam_role.mhc_backups.arn
  dr_backups         = true
  dr_region          = "us-east-1"
  aws_backup_tag_key = "mhc-nonprod-backup"
  type               = "EBS-"

  rules = [
    {
      name              = "mhc-nonprod-daily-EBS-rule"
      schedule          = "cron(0 07 * * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 960
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 14
      },
    },
  ]
}
