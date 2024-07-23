provider "aws" {
  region = "us-west-2"
}

module "ec2_instance_profiles" {
  source      = "../../../../modules/iam"
  environment = "NonProd"
}
