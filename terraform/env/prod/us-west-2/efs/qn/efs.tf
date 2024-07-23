provider "aws" {
  profile = "mhc"
  region  = "us-west-2"
  default_tags {
    tags = {
      "Environment" : "qn",
      "Role" : "EFS",
      "mhc-nonprod-backup" : "true"
    }
  }
}

module "efs" {
  source          = "../../../../../modules/efs"
  efs_kms         = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  subnets         = ["subnet-5ba7d12c", "subnet-d7ad06b3", "subnet-977bf3ce"] #yes["subnet-c48e20a0", "subnet-06bd7e70", "subnet-32ddcf6b"]
  vpc_id          = "vpc-0b10526e"
  env             = "qn"
  r53_hosted_zone = "Z2IX59JMXPQ6BD"
}

output "efs" {
  value = module.efs
}