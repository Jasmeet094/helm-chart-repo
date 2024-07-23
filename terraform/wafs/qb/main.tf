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
    key     = "c-mhc/waf-qb.tfstate"
    region  = "us-west-2"
    profile = "mhc"
    encrypt = false
  }
}

/*
QBLOG:
  QB      52.27.156.25
  QBLOGW1 52.27.156.25
QBS01:
  QBS01   52.11.113.76
  QBS01W1 52.11.113.76
QBS02:
  QBS02   52.38.221.220
  QBS02W1 52.38.221.220
*/

module "qblog" {
  source             = "../../modules/waf/"
  waf_name           = "qblog"
  subdomain          = "qblogw1"
  logging_prefix     = "qblog/"
  lb_arn             = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/qblog/87bad050fa731ed1"
  zone_id            = "Z1H1FL5HABSF5"
  additional_aliases = ["qb.mobilehealthconsumer.com"]
}

module "qbs01" {
  source             = "../../modules/waf/"
  waf_name           = "qbs01"
  subdomain          = "qbs01w1"
  logging_prefix     = "qbs01/"
  lb_arn             = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/qbs01/6a1e25ef03eb900b"
  zone_id            = "Z1H1FL5HABSF5"
  additional_aliases = ["qbs01.mobilehealthconsumer.com"]
}

module "qbs02" {
  source             = "../../modules/waf/"
  waf_name           = "qbs02"
  subdomain          = "qbs02w1"
  logging_prefix     = "qbs02/"
  lb_arn             = "arn:aws:elasticloadbalancing:us-west-2:913835907225:loadbalancer/app/qbs02/95cf5c55747117c2"
  zone_id            = "Z1H1FL5HABSF5"
  additional_aliases = ["qbs02.mobilehealthconsumer.com"]
}
