provider "aws" {
  profile = "mhc"
  region  = "us-west-2"
  default_tags {
   tags = {
     "Environment"    = local.environment
    (local.tag_backup) = "true"
    "Operations"     = local.tag_operations
    "Terraform"      = "True"
    "Ansible"        = "True"
   }
  }
}
provider "aws" {
  profile = "mhc"
  alias   = "us-east-1"
  region  = "us-east-1"
  default_tags {
    tags = {
     "Environment"    = local.environment
    (local.tag_backup) = "true"
    "Operations"     = local.tag_operations
    "Terraform"      = "True"
    "Ansible"        = "True"
   }
  }
}