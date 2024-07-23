module "vpc" {
  source = "../../../../modules/m-vpc"

  cidr_block = "172.30.0.0/16"
  tag_map    = {}

  subnet_layers = {
    public = {
      additional_tags         = { "ENV" = "NonProduction" }
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
    private = {
      additional_tags         = {}
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
      additional_tags         = {}
      map_public_ip_on_launch = "false"
      routes                  = {}
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
