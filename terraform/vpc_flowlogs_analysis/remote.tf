provider "aws" {
  alias   = "west2"
  profile = "${var.profile}"
  region  = "${var.region}"
}

terraform {
  backend "s3" {
    bucket  = "mhc-terraform-us-west-2"
    key     = "vpc-flowlogs/analysis.tfstate"
    region  = "us-west-2"
    profile = "mhc"
    encrypt = false
  }
}
