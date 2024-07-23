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
          az_index   = 0
          cidr_block = "10.0.24.0/21"
        }
        1 = {
          az_index   = 1
          cidr_block = "10.0.32.0/21"
        }
        2 = {
          az_index   = 2
          cidr_block = "10.0.40.0/21"
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
          az_index   = 0
          cidr_block = "10.0.96.0/21"
        }
        1 = {
          az_index   = 1
          cidr_block = "10.0.104.0/21"
        }
        2 = {
          az_index   = 2
          cidr_block = "10.0.112.0/21"
        }
      }
    }
    isolated = {
      additional_tags = {}
      map_public_ip_on_launch = "false"
      routes = {}
      subnets = {
        0 = {
          az_index   = 0
          cidr_block = "10.0.168.0/21"
        }
        1 = {
          az_index   = 1
          cidr_block = "10.0.176.0/21"
        }
        2 = {
          az_index   = 2
          cidr_block = "10.0.184.0/21"
        }
      }
    }
  }

}
