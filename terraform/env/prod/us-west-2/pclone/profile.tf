provider "aws" {
  profile = "mhc"
  region  = "us-west-2"
  default_tags {
   tags = {
    "Environment"    = local.environment
    "Backup"         = "NonProd"
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
    "Backup"         = "NonProd"
    "Terraform"      = "True"
    "Ansible"        = "True"
  }
  }
}