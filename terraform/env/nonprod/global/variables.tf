variable "profile" {
  default = "mhc-nonprod"
}

variable "region" {
  default = "us-west-2"
}

variable "environment" {
  default = "nonprod"
}

variable "tag_customer" {
  default = "MHC"
}

variable "tag_environment" {
  default = "nonprod"
}

variable "tag_costcenter" {
  default = "terraform"
}

variable "vpcid" {
  description = "What is the VPC ID which it will be used in?"
  default     = "vpc-03de208109aa7f072"
}

variable "dns_zone" {
  description = "Domain name, e.g. mysite.com"
  default     = "mhcnp.com"
}

variable "ssh_key" {
  description = "What SSH key should be used"
  default     = "mhcnp-openvpn"
}

variable "subnets" {
  type        = "list(string)"
  description = "What subnet should the box be in?"
  default     = ["subnet-0b6e98dc3fc101d71", "subnet-062595de173cc997d"]
}

variable "sg_default" {
  description = "The default VPC SG or another all-internal SG"
  default     = "sg-02b31333277482a3b"
}

variable "subdomain" {
  description = "The subnet for the DNS entry, e.g. vpn.$${var.dns_zone}"
  default     = "vpn"
}

variable "Environment" {
  description = "What Environment is this going to be used in?"
  default     = "All"
}

variable "instance_size" {
  description = "What Environment is this going to be used in?"
  default     = "t2.small"
}

variable "CostCenter" {
  description = "Who should be billed for this?"
  default     = "MHC"
}

variable "OpenVPNNameTag" {
  description = "What is the Name Tag value you want?"
  default     = "OpenVPN"
}

variable "VPC_CIDR" {
  description = "What is the VPC CIDR Block? This will be used for the SG"
  default     = "172.20.0.0/16"
}

variable "openvpn_ami_ids" {
  type = "map"
  default = {
    us-east-1 = ""
    us-west-2 = "ami-ffd74b87"
    us-west-1 = ""
    us-east-2 = ""
  }
}

