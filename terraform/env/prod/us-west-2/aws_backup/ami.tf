module "aws_mhc_backup_prod_ami" {
  source               = "../../../../modules/AWS_backup"
  client               = "mhc"
  env                  = "prod"
  kms_primary_key      = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  kms_dr_key           = "arn:aws:kms:us-east-1:913835907225:key/b26c62b3-65de-4145-aa8e-d00b60e09584"
  backup_role_name     = aws_iam_role.mhc_backups.name
  backup_role_arn      = aws_iam_role.mhc_backups.arn
  dr_backups           = true
  dr_region            = "us-east-1"
  aws_backup_tag_key   = "Backup"
  aws_backup_tag_value = "Prod"

  rules = [
    {
      name              = "mhc-prod-daily-rule"
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
      name              = "mhc-prod-weekly-rule"
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
      name              = "mhc-prod-monthly-rule"
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


module "aws_anthem_backup_prod_2020_ami" {
  source               = "../../../../modules/AWS_backup"
  client               = "anthem"
  env                  = "prod"
  kms_primary_key      = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712" #AWS_MobileHealthConsumer_Prod_2020
  kms_dr_key           = "arn:aws:kms:us-east-1:950511364051:key/1e8939f7-176f-4119-a505-315603ce2cad" #AWS_MobileHealthConsumer_DR_2020
  backup_role_name     = aws_iam_role.mhc_backups.name
  backup_role_arn      = aws_iam_role.mhc_backups.arn
  dr_backups           = true
  dr_region            = "us-east-1"
  aws_backup_tag_key   = "Backup"
  aws_backup_tag_value = "Anthem2020"
  year                 = "2020"


  rules = [
    {
      name              = "anthem-prod-daily-rule"
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
      name              = "anthem-prod-weekly-rule"
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
      name              = "anthem-prod-monthly-rule"
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



module "aws_anthem_backup_prod_2021_ami" {
  source               = "../../../../modules/AWS_backup"
  client               = "anthem"
  env                  = "prod"
  kms_primary_key      = "arn:aws:kms:us-west-2:950511364051:key/6b098555-b046-4e80-847f-3ec74f63dabd" #AWS_MobileHealthConsumer_Prod_2020
  kms_dr_key           = "arn:aws:kms:us-east-1:950511364051:key/4daa569d-1c1e-436f-b0be-82d711606d73" #AWS_MobileHealthConsumer_DR_2020
  backup_role_name     = aws_iam_role.mhc_backups.name
  backup_role_arn      = aws_iam_role.mhc_backups.arn
  dr_backups           = true
  dr_region            = "us-east-1"
  aws_backup_tag_key   = "Backup"
  aws_backup_tag_value = "Anthem2021"
  year                 = "2021"


  rules = [
    {
      name              = "anthem-prod-daily-rule"
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
      name              = "anthem-prod-weekly-rule"
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
      name              = "anthem-prod-monthly-rule"
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


module "aws_anthem_backup_prod_2022_ami" {
  source               = "../../../../modules/AWS_backup"
  client               = "anthem"
  env                  = "prod"
  kms_primary_key      = "arn:aws:kms:us-west-2:915106308636:key/ebf2c698-a44e-4529-8f2f-cdfd6a988768" #AWS_MobileHealthConsumer_Prod_2022
  kms_dr_key           = "arn:aws:kms:us-east-1:915106308636:key/54909fd0-17d7-47d5-bdf0-a315bb33bbc6" #AWS_MobileHealthConsumer_DR_2022
  backup_role_name     = aws_iam_role.mhc_backups.name
  backup_role_arn      = aws_iam_role.mhc_backups.arn
  dr_backups           = true
  dr_region            = "us-east-1"
  aws_backup_tag_key   = "Backup"
  aws_backup_tag_value = "Anthem2022"
  year                 = "2022"


  rules = [
    {
      name              = "anthem-prod-daily-rule"
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
      name              = "anthem-prod-weekly-rule"
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
      name              = "anthem-prod-monthly-rule"
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

module "aws_mhc_backup_nonprod_ami" {
  source               = "../../../../modules/AWS_backup"
  client               = "mhc"
  env                  = "nonprod"
  kms_primary_key      = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  kms_dr_key           = "arn:aws:kms:us-east-1:913835907225:key/b26c62b3-65de-4145-aa8e-d00b60e09584"
  backup_role_name     = aws_iam_role.mhc_backups.name
  backup_role_arn      = aws_iam_role.mhc_backups.arn
  dr_backups           = true
  dr_region            = "us-east-1"
  aws_backup_tag_key   = "Backup"
  aws_backup_tag_value = "NonProd"

  rules = [
    {
      name              = "mhc-nonprod-daily-rule"
      schedule          = "cron(0 07 * * ? *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 180
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 14
      },
    },
  ]
}
