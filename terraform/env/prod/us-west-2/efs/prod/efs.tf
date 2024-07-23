provider "aws" {
  profile = "mhc"
  region  = "us-west-2"
  default_tags {
   tags = {
    "Environment"    = local.environment
    "Backup"         = "Prod"
    "Terraform"      = "True"
   }
  }
}

locals {
  environment = "p"
}

module "efs" {
  source          = "../../../../../modules/efs"
  efs_kms         = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  subnets         = ["subnet-c58e20a1", "subnet-19bd7e6f", "subnet-33ddcf6a"]
  vpc_id          = "vpc-0b10526e"
  env             = local.environment
  r53_hosted_zone = "Z2IX59JMXPQ6BD"
}



output "efs" {
  value = module.efs
}