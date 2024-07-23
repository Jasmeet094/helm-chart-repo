provider "aws" {
  region = "us-east-1"
}

module "main" {
  source = "../../"
  
  nat_gateway_subnet_layer       = "protected"

  subnet_layers = {
    firewall = {
      additional_tags = {}
      map_public_ip_on_launch = "false"
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
        1 = {
          az_index = 1
          newbits  = 5
          netnum   = 1
        }
        2 = {
          az_index = 2
          newbits  = 5
          netnum   = 2
        }
      }
    }
    protected = {
      additional_tags = {}
      map_public_ip_on_launch = "true"
      routes = {}
      subnets = {
        0 = {
          az_index = 0
          newbits  = 5
          netnum   = 3
        }
        1 = {
          az_index = 1
          newbits  = 5
          netnum   = 4
        }
        2 = {
          az_index = 2
          newbits  = 5
          netnum   = 5
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
        1 = {
          az_index = 1
          newbits  = 5
          netnum   = 10
        }
        2 = {
          az_index = 2
          newbits  = 5
          netnum   = 11
        }
      }
    }
    isolated = {
      additional_tags = {}
      map_public_ip_on_launch = "false"
      routes = {}
      subnets = {
        0 = {
          az_index = 0
          newbits  = 5
          netnum   = 18
        }
        1 = {
          az_index = 1
          newbits  = 5
          netnum   = 19
        }
        2 = {
          az_index = 2
          newbits  = 5
          netnum   = 20
        }
      }
    }
  }

}
