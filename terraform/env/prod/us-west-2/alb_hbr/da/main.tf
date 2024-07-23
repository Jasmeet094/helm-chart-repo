locals {
  alb_info = {
    "da.mobilehealthconsumer.com"      = { tg = "dalogw-TG", instances = ["dalogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "dalogw1.mobilehealthconsumer.com" = { tg = "dalogw1-TG", instances = ["dalogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "das01w1.mobilehealthconsumer.com" = { tg = "das01w1-TG", instances = ["das01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "das02w1.mobilehealthconsumer.com" = { tg = "das02w1-TG", instances = ["das02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "dalog.mobilehealthconsumer.com"   = { tg = "dalogw-TG", instances = ["dalogw1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "das01.mobilehealthconsumer.com"   = { tg = "das01w-all-TG", instances = ["das01w*"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "das02.mobilehealthconsumer.com"   = { tg = "das02w-all-TG", instances = ["das02w*"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
  }

  cloudfront_alias = ["da.mobilehealthconsumer.com"]
  shard_root       = ["dalog.mobilehealthconsumer.com", "das01.mobilehealthconsumer.com", "das02.mobilehealthconsumer.com"]

  direct_to_lb    = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_da" {
  source     = "../../../../../modules/alb_hbr"
  env        = "DA"
  subnet_env = "QA"
  sg_env     = "DA"
  default_TG = "dalogw-TG"
  alb_info   = local.alb_info
}

module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "DA"
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
  records         = [module.alb_hbr_da.lb.dns_name]
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


resource "aws_route53_record" "lb-origin" {
  zone_id         = "Z2IX59JMXPQ6BD"
  name            = "da-origin"
  type            = "A"
  alias {
    name                   = module.alb_hbr_da.lb.dns_name
    zone_id                = module.alb_hbr_da.lb.zone_id
    evaluate_target_health = false
  }
  allow_overwrite = true
}
