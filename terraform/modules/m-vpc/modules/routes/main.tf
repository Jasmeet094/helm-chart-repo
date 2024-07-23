resource "aws_route" "igw_route" {
  count = var.target == "igw" ? 1 : 0

  route_table_id         = var.route_table_id
  destination_cidr_block = var.destination
  gateway_id             = var.resource_id
}

resource "aws_route" "nat_route" {
  count = var.target == "nat" ? 1 : 0

  route_table_id         = var.route_table_id
  destination_cidr_block = var.destination
  nat_gateway_id         = var.resource_id
}

resource "aws_route" "tgw_route" {
  count = var.target == "tgw" ? 1 : 0

  route_table_id         = var.route_table_id
  destination_cidr_block = var.destination
  transit_gateway_id     = var.resource_id
}

resource "aws_route" "vpce_route" {
  count = var.target == "vpce" ? 1 : 0

  route_table_id         = var.route_table_id
  destination_cidr_block = var.destination
  vpc_endpoint_id        = var.resource_id
}

resource "aws_route" "vpc_peering_route" {
  count = var.target == "pcx" ? 1 : 0

  route_table_id            = var.route_table_id
  destination_cidr_block    = var.destination
  vpc_peering_connection_id = var.resource_id
}
