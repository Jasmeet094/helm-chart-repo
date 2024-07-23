locals {
  alb_info = {
    "qb.mobilehealthconsumer.com"      = { tg = "qblogw-TG", instances = ["qblogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "qblogw1.mobilehealthconsumer.com" = { tg = "qblogw1-TG", instances = ["qblogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "qbs01w1.mobilehealthconsumer.com" = { tg = "qbs01w1-TG", instances = ["qbs01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "qbs02w1.mobilehealthconsumer.com" = { tg = "qbs02w1-TG", instances = ["qbs02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "qblog.mobilehealthconsumer.com"   = { tg = "qblogw-TG", instances = ["qblogw1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "qbs01.mobilehealthconsumer.com"   = { tg = "qbs01w-all-TG", instances = ["qbs01w*"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "qbs02.mobilehealthconsumer.com"   = { tg = "qbs02w-all-TG", instances = ["qbs02w*"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
    "bscqb.mobilehealthconsumer.com"   = { tg = "bscqbw-all-TG", instances = ["bscqbw*"], priority = "80", zone_id = "Z2IX59JMXPQ6BD" }
    "bscqbw1.mobilehealthconsumer.com" = { tg = "bscqbw1-TG", instances = ["bscqbw1"], priority = "90", zone_id = "Z2IX59JMXPQ6BD" }
    "qb.engagementpoint.com"           = { tg = "bscqbw1-TG", instances = ["bscqbw1"], priority = "100", zone_id = "Z011593229BAR9FZ8P3JN" }
  }

  cloudfront_alias = ["qb.mobilehealthconsumer.com"]
  shard_root       = ["qblog.mobilehealthconsumer.com", "qbs01.mobilehealthconsumer.com", "qbs02.mobilehealthconsumer.com"]
  direct_to_lb     = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls  = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_qb" {
  source     = "../../../../../modules/alb_hbr"
  env        = "QB"
  subnet_env = "QA"
  sg_env     = "QB"
  default_TG = "qblogw-TG"
  alb_info   = local.alb_info
  secondary_alb_cert = [
    "qa.engagementpoint.com"
  ]
}

module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "QB"
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr_qb.lb.dns_name
  acm_cert_arn   = data.aws_acm_certificate.main.arn
}

resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_qb.lb.dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "root-da" {
  for_each = local.cloudfront_urls

  zone_id = each.value
  name    = each.key
  type    = "A"
  alias {
    name                   = module.cloudfront.domain_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}