variable "region" {
  default = "us-west-2"
}

variable "server_count" {
  default = "1"
}

variable "sg_allhosts" {
  default = ""
}

variable "shard" {
  default = "s01"
}

variable "server" {
  default = "w1"
}

variable "env" {
  default = "p"
}

variable "ami" {
  default = "ami-031b1f872d286c170"
}

variable "profile" {
  default = "mhc"
}

variable "domain" {
  default = "mobilehealthconsumer.com"
}

variable "private_domain" {
  default = "mobhealthinternal.com"
}

variable "certificate_arn" {
  #default = "arn:aws:acm:us-west-2:913835907225:certificate/c17fdd6d-f578-4508-a315-dbd15c99422f"
  default = "arn:aws:iam::913835907225:server-certificate/wildcard-jan2018-mar2021"
}

variable "key_name" {
  default = "MHC-Prod"
}

#do we create a subnets_qa and subnets_prod, or just adjust
variable "subnets" {
  type = map(string)

  default = {
    s01 = "subnet-c58e20a1"
    s02 = "subnet-19bd7e6f"
    #s02 = "subnet-19bd7e6f" # prod
    s03 = "subnet-06bd7e70"
    s04 = "subnet-06bd7e70"
    s05 = "subnet-06bd7e70"
    s06 = "subnet-19bd7e6f"
    s09 = "subnet-19bd7e6f"
    s10 = "subnet-c58e20a1"
    s11 = "subnet-33ddcf6a"
    s12 = "subnet-c58e20a1"
    s14 = "subnet-c58e20a1"
    log = "subnet-19bd7e6f"
  }
}

#do we create a security_groups_qa and security_groups_prod, or just adjust
variable "security_groups" {
  type = map(string)

  default = {
    app               = "sg-83d314f9"
    db                = "sg-1ddf1867"
    lb                = "sg-5fde1925"
    general           = "sg-12667d75"
    external_services = "sg-2f1f1848"
    all_from_here     = "sg-c1ea7ca5"
    sftp              = "sg-a5b76bdd"
    ssh               = "sg-f5ea7c91"
    vpn               = "sg-7b64771f"
  }
}

variable "vpc" {
  default = "vpc-0b10526e"
}
