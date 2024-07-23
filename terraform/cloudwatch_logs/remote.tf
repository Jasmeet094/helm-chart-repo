terraform {
  backend "s3" {
    bucket  = "mhc-terraform-us-west-2"
    key     = "ops/cwl.tfstate"
    region  = "us-west-2"
    profile = "mhc"
    encrypt = true
  }
}
