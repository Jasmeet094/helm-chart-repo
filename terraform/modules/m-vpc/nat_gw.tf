locals {
  nat_instances = min(var.nat_instances, length(keys(var.subnet_layers[var.nat_gateway_subnet_layer].subnets)))
  nat_gateway_subnets = slice(
    [for subnet_name, subnet_data in var.subnet_layers[var.nat_gateway_subnet_layer].subnets :
      "${var.nat_gateway_subnet_layer}_${subnet_name}"
    ],
    0,
    local.nat_instances
  )
}

resource "aws_eip" "nat" {
  for_each = toset(local.nat_gateway_subnets)

  vpc = "true"

  tags = var.tag_map
}

resource "aws_nat_gateway" "main" {
  for_each = toset(local.nat_gateway_subnets)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.main[each.key].id
  depends_on    = [aws_internet_gateway.main]

  tags = var.tag_map
}
