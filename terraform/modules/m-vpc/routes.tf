locals {
  route_map = merge([for subnet_layer_name, subnet_layer_data in var.subnet_layers :
    merge([for subnet_name, subnet_data in subnet_layer_data.subnets :
      {for route_name, route_data in lookup(subnet_layer_data, "routes", {}) :
        "${subnet_layer_name}_${route_name}_${subnet_name}" => merge(route_data,
          {
            "route_table_key" = "${subnet_layer_name}_${subnet_name}"
            "az_index"        = subnet_data.az_index
          }
        )
      }
    ]...)
  ]...)
}

resource "aws_route_table" "main" {
  for_each = local.subnets_map

  vpc_id = aws_vpc.main.id
  tags   = each.value.tags
}

resource "aws_route_table_association" "main" {
  for_each = local.subnets_map

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.key].id
}

module "routes" {
  for_each = local.route_map

  source = "./modules/routes"

  destination    = each.value.destination
  resource_id    = each.value.target == "nat" ? aws_nat_gateway.main[element(local.nat_gateway_subnets, each.value.az_index)].id : aws_internet_gateway.main.id
  route_table_id = aws_route_table.main[each.value.route_table_key].id
  target         = each.value.target
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tag_map, {"Name" = "igw"})
}

resource "aws_route_table_association" "igw" {
  gateway_id     = aws_internet_gateway.main.id
  route_table_id = aws_route_table.igw.id
}
