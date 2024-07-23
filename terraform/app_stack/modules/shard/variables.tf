variable "env" {}

variable "shard" {
  default = "s01"
}

variable "az" {
  type = "map(string)"
  default = {
    s01 = "a"
    s02 = "b"
    s03 = "a"
    s04 = "b"
    s05 = "a"
    s06 = "b"
    s07 = "a"
    s08 = "b"
    s09 = "b"
    s10 = "a"
    s11 = "c"
    s12 = "a"
    log = "c"
  }
}

variable "region" {}
variable "sg_lb" {}
variable "lb_subnets" {
  type = "list(string)"
}
variable "certificate_arn" {}
variable "vpc" {}
variable "server" {
  default = ""
}
variable "domain" {}
variable "r53_zone_id" {}
variable "r53_private_zone_id" {}
variable "key" {}
variable "subnet" {}
variable "security_groups" {
  type = "map(string)"
}

variable "profiles" {
  type = "map(string)"
  default = {
    web = "WebServer"
    db  = "DBServer"
  }
}

variable "ami" {
  default = "ami-031b1f872d286c170"
}

variable "kms_key_id" {
# default = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65 "
 default = "arn:aws:kms:us-west-2:950511364051:key/24b9d676-6806-40db-a695-15b89f058712"# anthem  
}

variable "instance_type" {
  default = "t3.large"
}
