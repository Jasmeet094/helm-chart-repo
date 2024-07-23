# RDS Instance Module

Terraform module for creating and managing AWS RDS instances.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | (Optional) The allocated storage in gibibytes. | `number` | `400` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | (Optional) The AZ for the RDS instance. | `string` | `"us-west-2a"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | (Required) Name of DB subnet group. | `string` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | (Required) The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier. | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | (Optional) The RDS instance class. | `string` | `"db.r6i.4xlarge"` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | (Optional) The amount of provisioned IOPS. Setting this implies a storage\_type of io1 or gp3. | `number` | `12000` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) The ARN for the KMS encryption key. | `string` | `"arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | (Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. | `string` | `""` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | (Optional) Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | (Required) Name of the DB parameter group to associate. | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | (Optional) Password for the master DB user. If ommitted, DB user password will be stored in Secrets Manager. | `string` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | (Optional) standard, gp2, gp3, or io1 | `string` | `"gp3"` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Required) List of VPC security groups to associate. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The hostname of the RDS instance |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the db instance. |
<!-- END_TF_DOCS -->