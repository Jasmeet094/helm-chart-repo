provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# module "login" {
#   source              = "./modules/shard"
#   shard               = "log"
#   env                 = "${var.env}"
#   domain              = "${var.domain}"
#   sg_lb               = "${var.security_groups["lb"]}"
#   lb_subnets          = ["${var.subnets["log"]}", "${var.subnets["s02"]}"]
#   certificate_arn     = "${var.certificate_arn}"
#   vpc                 = "${var.vpc}"
#   region              = "${var.region}"
#   r53_zone_id         = "${data.aws_route53_zone.domain.zone_id}"
#   r53_private_zone_id = "${data.aws_route53_zone.internal.zone_id}"
#   subnet              = "${var.subnets["log"]}"
#   key                 = "${var.key_name}"
#   security_groups     = "${var.security_groups}"
# }

# module "s01" {
#   source              = "./modules/shard"
#   shard               = "s01"
#   env                 = "${var.env}"
#   domain              = "${var.domain}"
#   sg_lb               = "${var.security_groups["lb"]}"
#   lb_subnets          = ["${var.subnets["s01"]}", "${var.subnets["s02"]}"]
#   certificate_arn     = "${var.certificate_arn}"
#   vpc                 = "${var.vpc}"
#   region              = "${var.region}"
#   r53_zone_id         = "${data.aws_route53_zone.domain.zone_id}"
#   r53_private_zone_id = "${data.aws_route53_zone.internal.zone_id}"
#   subnet              = "${var.subnets["s01"]}"
#   key                 = "${var.key_name}"
#   security_groups     = "${var.security_groups}"
# }

# module "s02" {
#   source              = "./modules/shard"
#   shard               = "s05"
#   env                 = "${var.env}"
#   domain              = "${var.domain}"
#   sg_lb               = "${var.security_groups["lb"]}"
#   lb_subnets          = ["${var.subnets["s02"]}", "${var.subnets["s01"]}"]
#   certificate_arn     = "${var.certificate_arn}"
#   vpc                 = "${var.vpc}"
#   region              = "${var.region}"
#   r53_zone_id         = "${data.aws_route53_zone.domain.zone_id}"
#   r53_private_zone_id = "${data.aws_route53_zone.internal.zone_id}"
#   subnet              = "${var.subnets["s02"]}"
#   key                 = "${var.key_name}"
#   security_groups     = "${var.security_groups}"
# }

locals {
  shardid = "s14"
}

module "s02" {
  source              = "./modules/shard"
  shard               = "${local.shardid}"
  env                 = "${var.env}"
  domain              = "${var.domain}"
  sg_lb               = "${var.security_groups["lb"]}"
  lb_subnets          = ["${var.subnets[local.shardid]}", "${var.subnets[local.shardid]}"]
  certificate_arn     = "${var.certificate_arn}"
  vpc                 = "${var.vpc}"
  region              = "${var.region}"
  r53_zone_id         = "${data.aws_route53_zone.domain.zone_id}"
  r53_private_zone_id = "${data.aws_route53_zone.internal.zone_id}"
  subnet              = "${var.subnets[local.shardid]}"
  key                 = "${var.key_name}"
  security_groups     = "${var.security_groups}"
}


#resource "aws_route53_record" "env_dns" {
# lifecycle {
#   prevent_destroy = true
# }

#  zone_id = "${data.aws_route53_zone.domain.zone_id}"
#  name    = "${var.env}"
#  type    = "A"

#  alias {
#    name                   = "${module.s02.alb_dns}"
#    zone_id                = "${module.s02.alb_zone}"
#    evaluate_target_health = true
#  }
#}

#module "qas03" {
#  source              = "./modules/shard"
#  shard               = "s03"
#  env                 = "qa"
#  domain              = "${var.domain}"
#  sg_lb               = "${var.security_groups["lb"]}"
#  lb_subnets          = ["${var.subnets["s02"]}", "${var.subnets["s01"]}"]
#  certificate_arn     = "${var.certificate_arn}"
#  vpc                 = "${var.vpc}"
#  region              = "${var.region}"
#  r53_zone_id         = "${data.aws_route53_zone.domain.zone_id}"
#  r53_private_zone_id = "${data.aws_route53_zone.internal.zone_id}"
#  subnet              = "${var.subnets["s02"]}"
#  key                 = "${var.key_name}"
#  security_groups     = "${var.security_groups}"
#}
