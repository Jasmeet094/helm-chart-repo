locals {
  subnets_map = merge([for subnet_layer_name, subnet_layer_data in var.subnet_layers : {
      for subnet_name, subnet_data in subnet_layer_data.subnets : "${subnet_layer_name}_${subnet_name}" => {
        "layer" = subnet_layer_name
        "availability_zone" = element(data.aws_availability_zones.main.names, subnet_data.az_index % var.az_width)
        "cidr_block" = contains(keys(subnet_data), "cidr_block") ? subnet_data.cidr_block : cidrsubnet(var.cidr_block, subnet_data.newbits, subnet_data.netnum)
        "map_public_ip_on_launch" = subnet_layer_data.map_public_ip_on_launch
        "tags" = merge(var.tag_map, subnet_layer_data.additional_tags, { "Name" = "${subnet_layer_name}_${subnet_name}" })
      }
    }
  ]...)
}

resource "aws_subnet" "main" {
  for_each = local.subnets_map

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags                    = each.value.tags
}
