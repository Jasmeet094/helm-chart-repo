locals {
  alb_info = {
    "st.mobilehealthconsumer.com"      = { tg = "stlogw-TG", instances = ["stlogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "stlogw1.mobilehealthconsumer.com" = { tg = "stlogw1-TG", instances = ["stlogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "sts01w1.mobilehealthconsumer.com" = { tg = "sts01w1-TG", instances = ["sts01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "stlog.mobilehealthconsumer.com"   = { tg = "stlogw-TG", instances = ["stlogw1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "sts01.mobilehealthconsumer.com"   = { tg = "sts01w-all-TG", instances = ["sts01w*"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
  }
  cloudfront_alias = ["st.mobilehealthconsumer.com"]
  shard_root       = ["stlog.mobilehealthconsumer.com", "sts01.mobilehealthconsumer.com"]
  direct_to_lb     = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls  = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_st" {
  source     = "../../../../../modules/alb_hbr"
  env        = "ST"
  subnet_env = "QA"
  sg_env     = "ST"
  default_TG = "stlogw-TG"
  alb_info   = local.alb_info
}

module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "ST"
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr_st.lb.dns_name
  acm_cert_arn   = data.aws_acm_certificate.main.arn
}


resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_st.lb.dns_name]
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

