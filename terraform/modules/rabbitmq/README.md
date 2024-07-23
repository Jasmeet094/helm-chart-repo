# Terraform RabbitMQ Module

## Usage

```hcl
module "rabbitmq" {
  source = "../"

  friendly_name_prefix = "MQ"
  common_tags = {
    "App"         = "RabbitMQ"
    "Environment" = "dev"
    "Terraform"   = "True"
  }
  shard             = "test"
  vpc_id            = "vpc-0123456789abc"
  broker_subnet_ids = ["subnet-0123456789abc", "subnet-0123456789abc", "subnet-0123456789abc"]

  console_username = "mquser123"
  console_password = "mqpassword123"
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 4.37.0  |

## Resources

| Name                                                                                                                                                  | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_mq_broker.rabbit_mq_broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker)                               | resource |
| [aws_security_group.broker_ingress_allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                 | resource |
| [aws_security_group_rule.broker_ingress_ampqp_allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.broker_ingress_https_allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name                                                                                          | Description                                                              | Type           | Default              | Required |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | -------------- | -------------------- | :------: |
| <a name="input_broker_subnet_ids"></a> [broker_subnet_ids](#input_broker_subnet_ids)          | (Optional) List of subnet IDs to use for the RabbitMQ broker instance.   | `list(string)` | `[]`                 |    no    |
| <a name="input_common_tags"></a> [common_tags](#input_common_tags)                            | (Optional) Map of common tags for taggable AWS resources.                | `map(string)`  | `{}`                 |    no    |
| <a name="input_console_password"></a> [console_password](#input_console_password)             | (Required) RabbitMQ user password login.                                 | `string`       | n/a                  |   yes    |
| <a name="input_console_username"></a> [console_username](#input_console_username)             | (Required) RabbitMQ user console login.                                  | `string`       | n/a                  |   yes    |
| <a name="input_deployment_mode"></a> [deployment_mode](#input_deployment_mode)                | (Optional) RabbitMQ engine version.                                      | `string`       | `"CLUSTER_MULTI_AZ"` |    no    |
| <a name="input_engine_version"></a> [engine_version](#input_engine_version)                   | (Optional) RabbitMQ engine version.                                      | `string`       | `"3.9.16"`           |    no    |
| <a name="input_friendly_name_prefix"></a> [friendly_name_prefix](#input_friendly_name_prefix) | (Required) String value for friendly name prefix for AWS resource names. | `string`       | n/a                  |   yes    |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type)                      | (Optional) AmazonMQ broker instance type.                                | `string`       | `"mq.m5.large"`      |    no    |
| <a name="input_publicly_accessible"></a> [publicly_accessible](#input_publicly_accessible)    | (Optional) Whether to enable connections from outside of the VPC.        | `bool`         | `false`              |    no    |
| <a name="input_shard"></a> [shard](#input_shard)                                              | (Required) The name of the Shard                                         | `string`       | n/a                  |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                           | (Required) VPC ID that RabbitMQ broker will be deployed into.            | `string`       | n/a                  |   yes    |

## Outputs

| Name                                                              | Description |
| ----------------------------------------------------------------- | ----------- |
| <a name="output_broker_arn"></a> [broker_arn](#output_broker_arn) | n/a         |

<!-- END_TF_DOCS -->
