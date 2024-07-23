<!-- markdownlint-disable MD013 -->
# AWS Auto Patching Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_maintenance_window.window](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_task.run_patch_baseline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_patch_baseline.ubuntu_1804_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_baseline) | resource |
| [aws_ssm_patch_group.patchgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_group) | resource |
| [terraform_remote_state.s3_patching_logs](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_patch_filters"></a> [patch\_filters](#input\_patch\_filters) | List of patch filters used for approval rules | <pre>list(object({<br>    key    = string<br>    values = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "key": "PRODUCT",<br>    "values": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "key": "SECTION",<br>    "values": [<br>      "*"<br>    ]<br>  },<br>  {<br>    "key": "PRIORITY",<br>    "values": [<br>      "*"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_patch_group"></a> [patch\_group](#input\_patch\_group) | Tag value used to target instances for patching. | `string` | n/a | yes |
| <a name="input_sources"></a> [sources](#input\_sources) | List of Ubuntu 18.04 base repos | <pre>list(object({<br>    name          = string<br>    products      = list(string)<br>    configuration = string<br>  }))</pre> | <pre>[<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic main restricted",<br>    "name": "ubuntu-bionic-main",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic-updates main restricted",<br>    "name": "ubuntu-bionic-updates-main",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic universe",<br>    "name": "ubuntu-bionic-universe",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic-updates universe",<br>    "name": "ubuntu-bionic-updates-universe",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic multiverse",<br>    "name": "ubuntu-bionic-multiverse",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic-updates multiverse",<br>    "name": "ubuntu-bionic-updates-multiverse",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://us-west-2.ec2.archive.ubuntu.com/ubuntu/> bionic-backports main restricted universe multiverse",<br>    "name": "ubuntu-bionic-backports-main",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://security.ubuntu.com/ubuntu> bionic-security main restricted",<br>    "name": "ubuntu-bionic-security-main",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://security.ubuntu.com/ubuntu> bionic-security universe",<br>    "name": "ubuntu-bionic-security-universe",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  },<br>  {<br>    "configuration": "deb <http://security.ubuntu.com/ubuntu> bionic-security multiverse",<br>    "name": "ubuntu-bionic-security-multiverse",<br>    "products": [<br>      "Ubuntu18.04"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be added to associated resources | `map(string)` | <pre>{<br>  "Terraform": true<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->