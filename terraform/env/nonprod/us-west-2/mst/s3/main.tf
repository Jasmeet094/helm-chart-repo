provider "aws" {
  region = "us-west-2"
}

module "rabbitmq" {
  source = "../../../../../modules/s3"

  common_tags = {
    "Environment" = "ofog"
    "Terraform"   = "True"
  }
  environment = "ofog"
}
