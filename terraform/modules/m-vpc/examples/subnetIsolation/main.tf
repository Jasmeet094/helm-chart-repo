provider "aws" {
  region = "us-east-1"
}

module "main" {
  source = "../../"

  subnet_layers = {
    public = {
      additional_tags = {}
      map_public_ip_on_launch = "true"
      routes = {
        default = {
          destination = "0.0.0.0/0"
          target      = "igw"
        }
      }
      subnets = {
        0 = {
          az_index = 0
          newbits  = 5
          netnum   = 0
        }
      }
    }
    private = {
      additional_tags = {}
      map_public_ip_on_launch = "false"
      routes = {
        default = {
          destination = "0.0.0.0/0"
          target      = "nat"
        }
      }
      subnets = {
        0 = {
          az_index = 0
          newbits  = 5
          netnum   = 9
        }
      }
    }
    isolated = {
      additional_tags = {}
      map_public_ip_on_launch = "false"
      subnets = {
        0 = {
          az_index = 0
          newbits  = 5
          netnum   = 18
        }
      }
    }
  }

  nat_instances = 1
}

resource "random_string" "main" {
  length   = 6
  special  = false
  upper    = false
  numeric  = false
}

resource "aws_security_group" "main" {
  vpc_id = module.main.vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "aws_key_pair" "main" {
  public_key = tls_private_key.main.public_key_openssh
}

data "aws_ssm_parameter" "main" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_eip" "main" {
  instance = aws_instance.public.id
  vpc      = true
}

resource "aws_instance" "public" {
  ami                    = data.aws_ssm_parameter.main.value
  instance_type          = "t3.large"
  key_name               = aws_key_pair.main.key_name
  subnet_id              = module.main.subnets["public_0"].id
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "remote-exec" {
    # Used to verify instance is up/connectable before handing off to testing 
    # platform
    inline = ["touch /tmp/lol"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = tls_private_key.main.private_key_pem
    }
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ssm_parameter.main.value
  instance_type          = "t3.large"
  key_name               = aws_key_pair.main.key_name
  subnet_id              = module.main.subnets["private_0"].id
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "remote-exec" {
    # Used to verify instance is up/connectable before handing off to tests
    inline = ["touch /tmp/lol"]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      host                = self.private_ip
      private_key         = tls_private_key.main.private_key_pem
      bastion_host        = aws_eip.main.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = tls_private_key.main.private_key_pem
    }
  }
}

resource "aws_instance" "isolated" {
  ami                    = data.aws_ssm_parameter.main.value
  instance_type          = "t3.large"
  key_name               = aws_key_pair.main.key_name
  subnet_id              = module.main.subnets["isolated_0"].id
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "remote-exec" {
    # Used to verify instance is up/connectable before handing off to tests
    inline = ["touch /tmp/lol"]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      host                = self.private_ip
      private_key         = tls_private_key.main.private_key_pem
      bastion_host        = aws_eip.main.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = tls_private_key.main.private_key_pem
    }
  }
}

output "main" {
  value = {
    ip_public   = aws_eip.main.public_ip
    ip_private  = aws_instance.private.private_ip
    ip_isolated = aws_instance.isolated.private_ip
    ssh_key     = tls_private_key.main.private_key_pem
    ip_natgw    = module.main.eip_nat_gateway["public_0"].public_ip
  }
  sensitive = true
}
