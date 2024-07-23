# Terraform AWS IAM Role Module

This module manages EC2 Instance Roles for MHC.

## Roles created by this module

| Role Name | Role Description                                          |
| --------- | --------------------------------------------------------- |
| WebServer | Used by Web server instances for accessing AWS resources. |
| DBServer  | Used by DB server instances for accessing AWS resources.  |

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 4.48.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                    | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_instance_profile.db_server_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)                          | resource    |
| [aws_iam_instance_profile.web_server_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)                         | resource    |
| [aws_iam_policy.backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                  | resource    |
| [aws_iam_policy.cloudwatch_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                         | resource    |
| [aws_iam_policy.ec2_snapshot_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                            | resource    |
| [aws_iam_policy.iam_account_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                              | resource    |
| [aws_iam_policy.kms_encrypt_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                             | resource    |
| [aws_iam_policy.s3_put_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                    | resource    |
| [aws_iam_policy.s3_read_only_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                            | resource    |
| [aws_iam_role.db_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                          | resource    |
| [aws_iam_role.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                         | resource    |
| [aws_iam_role_policy_attachment.db_backup_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)        | resource    |
| [aws_iam_role_policy_attachment.db_cloudwatch_logs_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)      | resource    |
| [aws_iam_role_policy_attachment.db_ec2_snapshot_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)         | resource    |
| [aws_iam_role_policy_attachment.db_iam_account_alias_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)    | resource    |
| [aws_iam_role_policy_attachment.db_kms_encrypt_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)          | resource    |
| [aws_iam_role_policy_attachment.db_systems_manager_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)      | resource    |
| [aws_iam_role_policy_attachment.web_backup_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)       | resource    |
| [aws_iam_role_policy_attachment.web_cloudwatch_logs_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)     | resource    |
| [aws_iam_role_policy_attachment.web_ec2_snapshot_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)        | resource    |
| [aws_iam_role_policy_attachment.web_iam_account_alias_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)   | resource    |
| [aws_iam_role_policy_attachment.web_kms_encrypt_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)         | resource    |
| [aws_iam_role_policy_attachment.web_s3_put_logs_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)         | resource    |
| [aws_iam_role_policy_attachment.web_s3_read_only_bucket_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.web_systems_manager_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)     | resource    |
| [aws_iam_policy_document.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                    | data source |
| [aws_iam_policy_document.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                           | data source |
| [aws_iam_policy_document.ec2_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                              | data source |
| [aws_iam_policy_document.iam_account_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                         | data source |
| [aws_iam_policy_document.instance_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_iam_policy_document.kms_encrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                               | data source |
| [aws_iam_policy_document.s3_put_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                               | data source |
| [aws_iam_policy_document.s3_read_only_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                | data source |

## Inputs

| Name                                                               | Description                            | Type     | Default | Required |
| ------------------------------------------------------------------ | -------------------------------------- | -------- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input_environment) | (Required) The name of the Environment | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                      | Description                              |
| ----------------------------------------------------------------------------------------- | ---------------------------------------- |
| <a name="output_db_server_profile"></a> [db_server_profile](#output_db_server_profile)    | Name of the DB Server instance profile.  |
| <a name="output_web_server_profile"></a> [web_server_profile](#output_web_server_profile) | Name of the Web Server instance profile. |

<!-- END_TF_DOCS -->
