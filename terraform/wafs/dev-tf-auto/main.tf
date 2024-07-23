variable profile { default = "mhc" }
variable region { default = "us-west-2" }

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

provider "aws" {
  alias   = "east1"
  profile = "${var.profile}"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "mhc-terraform-us-west-2"
    key     = "c-mhc/waf_dev-tf-auto.tfstate"
    region  = "us-west-2"
    profile = "mhc"
    encrypt = false
  }
}

module "waf" {
  source         = "../../modules/waf/"
  waf_name       = "dev-tf-auto"
  subdomain      = "dev-tf-autos01w1"
  logging_prefix = "def-tf-auto/"
  lb_arn         = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/dev-tf-autolog-alb/cb7be24a3dacc0c9"
  zone_id        = "Z1H1FL5HABSF5"
}
