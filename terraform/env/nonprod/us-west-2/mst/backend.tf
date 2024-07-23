terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket  = "mhc-terraformstate-us-west-2-prod"
    key     = "terraform/env/nonprod/us-west-2/mst"
    region  = "us-west-2"
    profile = "mhc"
  }
}
