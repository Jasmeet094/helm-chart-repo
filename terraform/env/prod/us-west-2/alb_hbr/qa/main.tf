locals {
  alb_info = {
    "qa.mobilehealthconsumer.com"      = { tg = "qalogw-TG", instances = ["qalogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "qalogw1.mobilehealthconsumer.com" = { tg = "qalogw1-TG", instances = ["qalogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "qas01w1.mobilehealthconsumer.com" = { tg = "qas01w1-TG", instances = ["qas01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "qas02w1.mobilehealthconsumer.com" = { tg = "qas02w1-TG", instances = ["qas02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "qas03w1.mobilehealthconsumer.com" = { tg = "qas03w1-TG", instances = ["qas03w1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "qas04w1.mobilehealthconsumer.com" = { tg = "qas04w1-TG", instances = ["qas04w1"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "qalog.mobilehealthconsumer.com"   = { tg = "qalogw-TG", instances = ["qalogw1"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
    "qas01.mobilehealthconsumer.com"   = { tg = "qas01w-all-TG", instances = ["qas01w*"], priority = "80", zone_id = "Z2IX59JMXPQ6BD" }
    "qas02.mobilehealthconsumer.com"   = { tg = "qas02w-all-TG", instances = ["qas02w*"], priority = "90", zone_id = "Z2IX59JMXPQ6BD" }
    "qas03.mobilehealthconsumer.com"   = { tg = "qas03w-all-TG", instances = ["qas03w*"], priority = "100", zone_id = "Z2IX59JMXPQ6BD" }
    "qas04.mobilehealthconsumer.com"   = { tg = "qas04w-all-TG", instances = ["qas04w*"], priority = "110", zone_id = "Z2IX59JMXPQ6BD" }
    "qas04.mobhealthinternal.com"      = { tg = "qas04w-all-TG", instances = ["qas04w*"], priority = "120", zone_id = "Z1G1UDKK3Y11OQ" }
    "qas04w1.mobhealthinternal.com"    = { tg = "qas04w1-TG", instances = ["qas04w1"], priority = "121", zone_id = "Z1G1UDKK3Y11OQ" }
    "qa.mobhealthinternal.com"         = { tg = "qalogw-TG", instances = ["qalogw*"], priority = "130", zone_id = "Z1G1UDKK3Y11OQ" }
    "bscqa.mobilehealthconsumer.com"   = { tg = "bscqaw-all-TG", instances = ["bscqaw*"], priority = "140", zone_id = "Z2IX59JMXPQ6BD" }
    "bscqaw1.mobilehealthconsumer.com" = { tg = "bscqaw1-TG", instances = ["bscqaw1"], priority = "150", zone_id = "Z2IX59JMXPQ6BD" }
    "qa.engagementpoint.com"           = { tg = "bscqaw1-TG", instances = ["bscqaw1"], priority = "160", zone_id = "Z011593229BAR9FZ8P3JN" }
    # "qas05.mobilehealthconsumer.com"   = { tg = "qas05w-all-TG", instances = ["qas05w*"], priority = "170", zone_id = "Z2IX59JMXPQ6BD" }
    # "qas05w1.mobilehealthconsumer.com" = { tg = "qas05w1-all-TG", instances = ["qas05w1"], priority = "180", zone_id = "Z2IX59JMXPQ6BD" }
  }

  cloudfront_alias = ["qa.mobilehealthconsumer.com"]
  shard_root       = ["qalog.mobilehealthconsumer.com", "qas01.mobilehealthconsumer.com", "qas02.mobilehealthconsumer.com", "qas03.mobilehealthconsumer.com", "qas04.mobilehealthconsumer.com"]
  direct_to_lb     = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls  = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_qa" {
  source     = "../../../../../modules/alb_hbr"
  env        = "QA"
  subnet_env = "QA"
  sg_env     = "QA"
  default_TG = "qalogw-TG"
  alb_info   = local.alb_info
  secondary_alb_cert = [
    "qa.engagementpoint.com",
    "*.mobhealthinternal.com"
  ]
}

module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "QA"
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr_qa.lb.dns_name
  acm_cert_arn   = data.aws_acm_certificate.main.arn
  wp_site_url    = "mobilehealth44.wpengine.com"
}

resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_qa.lb.dns_name]
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
