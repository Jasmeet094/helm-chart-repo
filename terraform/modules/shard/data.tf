data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "aws_subnets" "selected" {
  tags = {
    Name = var.subnet_name
  }
   filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# data "aws_subnet" "selected" {
#   id = data.aws_subnets.selected[0].id
# }

data "aws_vpc" "selected" {
  id = var.vpc_id
}
