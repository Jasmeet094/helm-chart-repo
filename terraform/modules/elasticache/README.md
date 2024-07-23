# AWS Redis Elasticache Terraform Module

Terraform module for managing AWS Elasticache cluster for Redis.

## Usage

```
module "es" {
  source = "../"

  friendly_name_prefix = "mhc"
  common_tags = {
    "Terraform" = "True"
  }
  environment          = "test"
  vpc_id               = "vpc-1234567890abc"
  description          = "mhc ofog redis cluster"
  replication_group_id = "ofog-redis-cluster"
  redis_subnet_ids     = ["subnet-abc1234567890", "subnet-def1234567890", "subnet-ghi1234567890"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_elasticache_replication_group.redis_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.redis_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_security_group.redis_ingress_allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.redis_ingress_allow_6379](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | (Optional) Specifies whether any modifications are applied immediately, or during the next maintenance window. | `bool` | `true` | no |
| <a name="input_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#input\_at\_rest\_encryption\_enabled) | (Optional) Whether to enable encryption at rest. | `bool` | `true` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | (Optional) Specifies whether minor version engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window. | `bool` | `true` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | (Optional) Map of common tags for taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | (Required) User-created description for the replication group. | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) Version number of the cache engine to be used for the cache clusters in this replication group. | `string` | `"6.x"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) The name of the environment. | `string` | n/a | yes |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | (Required) String value for friendly name prefix for AWS resource names. | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | (Optional) Instance class to be used. | `string` | `"cache.m5.large"` | no |
| <a name="input_num_node_groups"></a> [num\_node\_groups](#input\_num\_node\_groups) | (Optional) Number of node groups (shards) for this Redis replication group. | `number` | `1` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | (Required unless replication\_group\_id is provided) The name of the parameter group to associate with this cache cluster. | `string` | `"default.redis6.x"` | no |
| <a name="input_preferred_cache_cluster_azs"></a> [preferred\_cache\_cluster\_azs](#input\_preferred\_cache\_cluster\_azs) | (Optional) List of EC2 availability zones in which the replication group's cache clusters will be created. | `list(string)` | `[]` | no |
| <a name="input_redis_subnet_ids"></a> [redis\_subnet\_ids](#input\_redis\_subnet\_ids) | List of subnet IDs to use for Redis Subnet Group. Private subnets is the best practice. | `list(string)` | `[]` | no |
| <a name="input_replicas_per_node_group"></a> [replicas\_per\_node\_group](#input\_replicas\_per\_node\_group) | (Optional) Number of replica nodes in each node group. Valid values are 0 to 5. | `number` | `1` | no |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | (Required) Replication group identifier. This parameter is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) VPC ID that RabbitMQ broker will be deployed into. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_address"></a> [endpoint\_address](#output\_endpoint\_address) | Endpoint address of the redis elasticache cluster. |
| <a name="output_redis_cluster_arn"></a> [redis\_cluster\_arn](#output\_redis\_cluster\_arn) | ARN of the redis elasticache cluster. |
<!-- END_TF_DOCS -->
