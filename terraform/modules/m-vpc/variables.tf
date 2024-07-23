variable "az_width" {
  description = "Controls how many AvailabilityZones this VPC should try to span per subnet layer. Note, if var.az_width is greater than the actual AZs available in a given region then the index is wrapped around by taking the index modulo of the length of the actual AZ list"
  default     = "3"
}

variable "cidr_block" {
  description = "The CIDR block this VPC will cover."
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "Controls whether instances in this VPC launch with dedicated tenancy or not. By default they do not."
  default     = "default"
}

variable "nat_instances" {
  description = "The number of NAT gateways to install. Note, this number must greater than or equal to var.subnet_map.private."
  default     = "3"
}

variable "nat_gateway_subnet_layer" {
  description = "The subnet layer to locate the nat gateway instances in.  The value provided here must exist as a key in the subnet_layers input."
  default     = "public"
}

variable "subnet_layers" {
  description = "A map of subnet-layers as keys, and subnets configuration per layer as values.  Each value specifies number of subnets, which AZs they are placed in, and other subnet attributes."

  default = {
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

variable "tag_map" {
  description = "A default tag map to be placed on all possible resources created by this module."

  default = {
    Name        = "FogSource"
    Application = "PoetryGenerator"
    CostCenter  = "Networking"
    Environment = "Demo"
    Customer    = "VogonCorp"
  }
}

variable "enable_flow_logs" {
  description = "A bool determining whether to enable flow-logs for this vpc to an S3 bucket."
  default     = false
}

variable "flow_log_bucket" {
  description = "The ARN of the bucket to which flow-logs will be directed. Note: if var.enable_flow_logs is true and this is variable is not changed, a bucket will be created."
  default     = ""
}
