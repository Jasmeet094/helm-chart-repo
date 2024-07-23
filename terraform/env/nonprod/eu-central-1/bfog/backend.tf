terraform {
  backend "s3" {
    bucket  = "mhc-terraformstate-us-west-2-prod"
    key     = "terraform/env/prod/us-west-2/bfog"
    region  = "us-west-2"
    profile = "mhc"
  }
}
