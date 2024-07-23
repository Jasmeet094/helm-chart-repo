terraform {
  backend "s3" {
    bucket  = "mhc-nonprod-terraform-us-west-2"
    key     = "terraform_regional_vpc.tfstate"
    region  = "us-west-2"
    profile = "mhc-nonprod"
  }
}
