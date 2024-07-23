locals {
  alb_info = {
    "pt.mobilehealthconsumer.com"       = { tg = "pts01w1-TG", instances = ["pts01w1"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "prodtest.mobilehealthconsumer.com" = { tg = "pts01w1-TG", instances = ["pts01w1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "pts01w1.mobilehealthconsumer.com"  = { tg = "pts01w1-TG", instances = ["pts01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "pts01.mobilehealthconsumer.com"    = { tg = "pts01w1-TG", instances = ["pts01w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
  }

  cloudfront_alias = ["pt.mobilehealthconsumer.com", "prodtest.mobilehealthconsumer.com"]
  shard_root       = ["pts01.mobilehealthconsumer.com"]

  direct_to_lb    = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_pt" {
  source     = "../../../../../modules/alb_hbr"
  env        = "PT"
  subnet_env = "QA"
  sg_env     = "PT"
  default_TG = "pts01w1-TG"
  alb_info   = local.alb_info
}

module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "PT"
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr_pt.lb.dns_name
  acm_cert_arn   = data.aws_acm_certificate.main.arn
}


resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_pt.lb.dns_name]
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

