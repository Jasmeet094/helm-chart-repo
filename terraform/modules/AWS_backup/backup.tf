provider "aws" {
  region  = var.aws_region
  profile = "mhc" # we need to fix this
}

provider "aws" {
  alias   = "dr"
  region  = var.dr_region
  profile = "mhc" # we need to fix this
}

variable "aws_region" {
  default = "us-west-2"
}

variable "client" {
  default = "MHC"
}

variable "year" {
  default = ""
}


variable "rules" {
  #  type = list
  default = []
}

variable "env" {
  default = "prod"
}

variable "dr_backups" {
  default = true
}

variable "kms_primary_key" {
  default = ""
}

variable "kms_dr_key" {
  default = ""
}

variable "dr_region" {
  default = ""
}

variable "aws_backup_tag_key" {
  default = ""
}

variable "backup_role_name" {
  default = ""
}

variable "backup_role_arn" {
  default = ""
}

variable "aws_backup_tag_value" {
  default = "true"
}

variable "type" {
  default = ""
}

#data "aws_kms_alias" "MHC_EBS_PROD" {
#  name = "alias/${var.kms_key_alias}"
#}

resource "aws_backup_vault" "mhc_ebs_backup_vault" {
  name        = "${var.client}-${var.env}-${var.type}Vault${var.year}"
  kms_key_arn = var.kms_primary_key
}

resource "aws_backup_vault" "mhc_DR_ebs_backup_vault" {
  count       = var.dr_backups ? 1 : 0
  name        = "${var.client}-${var.env}-DR-${var.type}Vault${var.year}"
  kms_key_arn = var.kms_dr_key
  provider    = aws.dr
}

resource "aws_backup_plan" "mhc_ebs_backup_plan" {
  name = "${var.client}-${var.env}-${var.type}plan${var.year}"

  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name         = lookup(rule.value, "name", null)
      target_vault_name = aws_backup_vault.mhc_ebs_backup_vault.name
      schedule          = lookup(rule.value, "schedule", null)
      start_window      = lookup(rule.value, "start_window", null)
      completion_window = lookup(rule.value, "completion_window", null)

      # LifeCycle
      dynamic "lifecycle" {
        for_each = length(lookup(rule.value, "lifecycle")) == 0 ? [] : [lookup(rule.value, "lifecycle", {})]
        content {
          #cold_storage_after = 0 add this when aws backup supports it for EBS
          delete_after = lookup(lifecycle.value, "delete_after", 90)
        }
      }

      #Copy Action
      dynamic "copy_action" {
        for_each = length(lookup(rule.value, "copy_action", {})) == 0 ? [] : [lookup(rule.value, "copy_action", {})]
        content {
          destination_vault_arn = aws_backup_vault.mhc_DR_ebs_backup_vault[0].arn

          # Copy Action Lifecycle
          dynamic "lifecycle" {
            for_each = length(lookup(copy_action.value, "lifecycle", {})) == 0 ? [] : [lookup(copy_action.value, "lifecycle", {})]
            content {
              cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
              delete_after       = lookup(lifecycle.value, "delete_after", 90)
            }
          }
        }
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "mhc_backups" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = var.backup_role_name
}

resource "aws_backup_selection" "mhc_ebs_backup_selection" {
  iam_role_arn = var.backup_role_arn
  name         = "mch_ebs_backup_selection"
  plan_id      = aws_backup_plan.mhc_ebs_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.aws_backup_tag_key
    value = var.aws_backup_tag_value
  }
}
