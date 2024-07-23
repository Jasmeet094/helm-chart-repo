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
    key     = "c-mhc/waf-qa.tfstate"
    region  = "us-west-2"
    profile = "mhc"
    encrypt = false
  }
}

/*
QALOG:
  QA      52.39.37.155
  QALOGW1 52.39.37.155
QAS01:
  QAS01W1 52.38.51.102
  QAS01   52.38.51.102, 52.11.109.89
QAS02:
  QAS02   54.149.250.134
  QAS02W1 54.149.250.134
*/

module "qalog" {
  source             = "../../modules/waf/"
  waf_name           = "qalog"
  subdomain          = "qalogw1"
  logging_prefix     = "qalog/"
  additional_aliases = ["qa.mobilehealthconsumer.com"]
  zone_id            = "Z1H1FL5HABSF5"
  lb_arn             = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/qalog-elb/342eb312e09848ba"
}

module "qas01" {
  source             = "../../modules/waf/"
  waf_name           = "qas01"
  subdomain          = "qas01w1"
  logging_prefix     = "qas01/"
  additional_aliases = ["qas01.mobilehealthconsumer.com"]
  zone_id            = "Z1H1FL5HABSF5"
  lb_arn             = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/QAS01ALB1/aa35d8f5c3b61ce2"
}

module "qas02" {
  source             = "../../modules/waf/"
  waf_name           = "qas02"
  subdomain          = "qas02w1"
  logging_prefix     = "qas02/"
  additional_aliases = ["qas02.mobilehealthconsumer.com"]
  zone_id            = "Z1H1FL5HABSF5"
  lb_arn             = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/qas02w1/542f7cc97612f618"
}
