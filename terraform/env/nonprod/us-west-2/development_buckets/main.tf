provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Terraform = "True"
    }
  }
}

# This bucket was created outside terraform
# module "mhcdevbucket" {
#   source = "../../../../modules/s3"

#   bucket_name = "mhcdevbucket"
#   environment = "NonProd"
# }

module "mhcqabucket" {
  source = "../../../../modules/s3"

  bucket_name = "mhcqabucket"
  environment = "NonProd"
}

module "mhcqaexperimentalbucket" {
  source = "../../../../modules/s3"

  bucket_name = "mhcqaexperimentalbucket"
  environment = "NonProd"
}

module "mhcothernonprodbucket" {
  source = "../../../../modules/s3"

  bucket_name = "mhcothernonprodbucket"
  environment = "NonProd"
}

