locals {
  alb_info = {
    "op.mobilehealthconsumer.com"      = { tg = "oplogw-TG", instances = ["oplogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "oplogw1.mobilehealthconsumer.com" = { tg = "oplogw1-TG", instances = ["oplogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "ops01w1.mobilehealthconsumer.com" = { tg = "ops01w1-TG", instances = ["ops01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "ops02w1.mobilehealthconsumer.com" = { tg = "ops02w1-TG", instances = ["ops02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "oplog.mobilehealthconsumer.com"   = { tg = "oplogw-TG", instances = ["oplogw1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "ops01.mobilehealthconsumer.com"   = { tg = "ops01w-all-TG", instances = ["ops01w*"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "ops02.mobilehealthconsumer.com"   = { tg = "ops02w-all-TG", instances = ["ops02w*"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
  }
  cloudfront_alias = ["op.mobilehealthconsumer.com"]
  shard_root       = ["oplog.mobilehealthconsumer.com", "ops01.mobilehealthconsumer.com", "ops02.mobilehealthconsumer.com"]

  direct_to_lb    = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_op" {
  source     = "../../../../../modules/alb_hbr"
  env        = "OP"
  subnet_env = "QA"
  sg_env     = "OP"
  default_TG = "oplogw-TG"
  alb_info   = local.alb_info
}

module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "OP"
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = aws_route53_record.lb-origin.fqdn
  acm_cert_arn   = data.aws_acm_certificate.main.arn
}

resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_op.lb.dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "root" {
  for_each = local.cloudfront_urls
  zone_id  = each.value
  name     = each.key
  type     = "A"
  alias {
    name                   = module.cloudfront.domain_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "lb-origin" {
  zone_id         = "Z2IX59JMXPQ6BD"
  name            = "op-origin"
  type            = "A"
  alias {
    name                   = module.alb_hbr_op.lb.dns_name
    zone_id                = module.alb_hbr_op.lb.zone_id
    evaluate_target_health = false
  }
  allow_overwrite = true
}
