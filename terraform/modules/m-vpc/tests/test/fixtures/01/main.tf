provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

module "vpc" {
  source = "../../../.."

  nat_instances = "1"

  subnet_map = {
    public   = "1"
    private  = "1"
    isolated = "1"
  }
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "aws_key_pair" "main" {
  public_key = tls_private_key.main.public_key_openssh
}

resource "aws_security_group" "main" {
  vpc_id = module.vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "public" {
  ami           = data.aws_ami.al2.id
  instance_type = "t2.medium"

  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.id

  subnet_id = module.vpc.subnets.public.0.id

  associate_public_ip_address = true
}

resource "aws_instance" "private" {
  ami           = data.aws_ami.al2.id
  instance_type = "t2.medium"

  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.id

  subnet_id = module.vpc.subnets.private.0.id

  associate_public_ip_address = true

  provisioner "remote-exec" {
    # Used to verify instance is up/connectable before handing off to testing 
    # platform
    script = "network-conn.sh"

    connection {
      type                = "ssh"
      user                = "ec2-user"
      host                = self.private_ip
      private_key         = tls_private_key.main.private_key_pem
      bastion_host        = aws_instance.public.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = tls_private_key.main.private_key_pem
    }
  }
}


resource "aws_instance" "isolated" {
  ami           = data.aws_ami.al2.id
  instance_type = "t2.medium"

  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.id

  subnet_id = module.vpc.subnets.isolated.0.id

  associate_public_ip_address = true

  provisioner "remote-exec" {
    # Used to verify instance is up/connectable before handing off to tests
    inline = ["touch /tmp/lol.txt"]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      host                = self.private_ip
      private_key         = tls_private_key.main.private_key_pem
      bastion_host        = aws_instance.public.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = tls_private_key.main.private_key_pem
    }
  }
}

resource "random_string" "main" {
  length  = 8
  special = false
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "key.pem"
  file_permission = "600"
}

output "ip_public" {
  value = aws_instance.public.public_ip
}

output "ip_private" {
  value = aws_instance.private.private_ip
}

output "ip_isolated" {
  value = aws_instance.isolated.private_ip
}
