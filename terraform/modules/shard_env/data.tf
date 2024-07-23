data "aws_subnets" "selected" {
  tags = {
    Name = var.subnet_name
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}
