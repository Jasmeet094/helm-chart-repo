# aws-vpc routes sub-module

This repo contains a [Terraform module](https://www.terraform.io/docs/modules/usage.html) to deploy routes to an aws' vpc with options common to most applications. It is designed to be used as a companion to [m-vpc](https://github.com/FoghornConsulting/m-vpc) or standalone as needed.

License information can be found in [LICENSE.md](./LICENSE.md) in this same repo.

## Features
* Support for NAT Gateway, Internet Gateway, Transit Gateway, VPC Endpoint, and VPC Peering Connection targets
* Generic target resource_id interface reduces complexity of `aws_route` implementation

## How to use this module
```
module "route" {
 source = "git@github.com:FogSource/m-vpc//modules/routes?ref=v3.0.2"

 destination    = "0.0.0.0/0"
 resource_id    = "igw-123456789"
 route_table_id = "rtb-123456789"
 target         = "igw"
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.igw_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.tgw_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpc_peering_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpce_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination"></a> [destination](#input\_destination) | The CIDR block for the destination traffic for the route. | `any` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The resource identifier for the specific target type.  Valid values here include internet gateway id, nat gateway id, transit gateway id, vpc endpoint id, and vpc peering connection id, specifically related to the value provided in target. | `any` | n/a | yes |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | The route table id to add the route to. | `any` | n/a | yes |
| <a name="input_target"></a> [target](#input\_target) | The type of target for the route.  Value values here include igw, nat, tgw, vpce, and pcx. | `any` | n/a | yes |

## Outputs

No outputs.
