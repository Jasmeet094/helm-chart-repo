# RDS Parameter Group Module

Create and manage AWS RDS parameter groups for postgres.

## Usage
```hcl
module "parameter_group" {
  source = "../"

  name        = "pg_group"
  description = "pg group 1"
  parameters  = {
    {
      name         = "max_connections",
      value        = "LEAST({DBInstanceClassMemory/9531392},5000)",
      apply_method = "pending-reboot"
    },
    {
      name         = "maintenance_work_mem",
      value        = "GREATEST({DBInstanceClassMemory*1024/63963136},65536)",
      apply_method = "immediate"
    },
  }
}
```

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
| [aws_db_parameter_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional, Forces new resource) The description of the DB parameter group. | `string` | `"Managed by Terraform"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required, Forces new resource) The name of the DB parameter group. | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | A list of DB parameters to apply. | <pre>list(object({<br>    name         = string<br>    value        = any<br>    apply_method = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The arn of the DB parameter group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the DB parameter group. |
<!-- END_TF_DOCS -->