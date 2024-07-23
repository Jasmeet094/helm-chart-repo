terraform {
  backend "s3" {
    bucket  = "mhc-terraform-us-west-2"
    key     = "terraform_regional_alb_fixed_response.tfstate"
    region  = "us-west-2"
    profile = "mhc"
  }
}

