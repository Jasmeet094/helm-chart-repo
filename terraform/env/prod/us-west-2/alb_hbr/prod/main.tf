locals {
  alb_info = {
    "www.mobilehealthconsumer.com"    = { tg = "plogw-TG", instances = ["plogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "plogw1.mobilehealthconsumer.com" = { tg = "plogw1-TG", instances = ["plogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "ps01w1.mobilehealthconsumer.com" = { tg = "ps01w1-TG", instances = ["ps01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "ps02w1.mobilehealthconsumer.com" = { tg = "ps02w1-TG", instances = ["ps02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "ps03w1.mobilehealthconsumer.com" = { tg = "ps03w1-TG", instances = ["ps03w1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "ps04w1.mobilehealthconsumer.com" = { tg = "ps04w1-TG", instances = ["ps04w1"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "ps05w1.mobilehealthconsumer.com" = { tg = "ps05w1-TG", instances = ["ps05w1"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
    "plog.mobilehealthconsumer.com"   = { tg = "plogw-TG", instances = ["plogw*"], priority = "80", zone_id = "Z2IX59JMXPQ6BD" }
    "ps01.mobilehealthconsumer.com"   = { tg = "ps01w-all-TG", instances = ["ps01w2", "ps01w3", "ps01w4"], priority = "90", zone_id = "Z2IX59JMXPQ6BD" }
    "ps02.mobilehealthconsumer.com"   = { tg = "ps02w-all-TG", instances = ["ps02w2", "ps02w3", "ps02w4"], priority = "100", zone_id = "Z2IX59JMXPQ6BD" }
    "ps03.mobilehealthconsumer.com"   = { tg = "ps03w-all-TG", instances = ["ps03w*"], priority = "110", zone_id = "Z2IX59JMXPQ6BD" }
    "ps04.mobilehealthconsumer.com"   = { tg = "ps04w-all-TG", instances = ["ps04w*"], priority = "120", zone_id = "Z2IX59JMXPQ6BD" }
    "ps05.mobilehealthconsumer.com"   = { tg = "ps05w-all-TG", instances = ["ps05w*"], priority = "130", zone_id = "Z2IX59JMXPQ6BD" }
    "mobilehealthconsumer.com"        = { tg = "plogw-TG", instances = ["plogw*"], priority = "140", zone_id = "Z2IX59JMXPQ6BD" }
    "engagementpoint.com"             = { tg = "plogw-TG", instances = ["plogw*"], priority = "150", zone_id = "Z011593229BAR9FZ8P3JN" }
    "www.engagementpoint.com"         = { tg = "plogw-TG", instances = ["plogw*"], priority = "160", zone_id = "Z011593229BAR9FZ8P3JN" }
    "ps05.engagementpoint.com"        = { tg = "ps05w1-all-TG", instances = ["ps05w*"], priority = "170", zone_id = "Z011593229BAR9FZ8P3JN" }
    "ps06w1.mobilehealthconsumer.com" = { tg = "ps06w1-TG", instances = ["ps06w1"], priority = "180", zone_id = "Z2IX59JMXPQ6BD" }
    "ps06.mobilehealthconsumer.com"   = { tg = "ps06w-all-TG", instances = ["ps06w2"], priority = "190", zone_id = "Z2IX59JMXPQ6BD" }
    "ps07w1.mobilehealthconsumer.com" = { tg = "ps07w1-TG", instances = ["ps07w1"], priority = "200", zone_id = "Z2IX59JMXPQ6BD" }
    "ps07.mobilehealthconsumer.com"   = { tg = "ps07w-all-TG", instances = ["ps07w2", "ps07w3"], priority = "210", zone_id = "Z2IX59JMXPQ6BD" }
    "alightwell.com"                  = { tg = "plogw-TG", instances = ["plogw*"], priority = "220", zone_id = "xxxxxxxxxxxxx" }
    "www.alightwell.com"              = { tg = "plogw-TG", instances = ["plogw*"], priority = "230", zone_id = "xxxxxxxxxxxxx" }
    "ps07.alightwell.com"             = { tg = "ps07w-all-TG", instances = ["ps07w2", "ps07w3"], priority = "240", zone_id = "xxxxxxxxxxxxx" }
    "ps08.mobilehealthconsumer.com"   = { tg = "ps08w-all-TG", instances = ["ps08w2"], priority = "250", zone_id = "Z2IX59JMXPQ6BD" }
    "ps08w1.mobilehealthconsumer.com"   = { tg = "ps08w1-TG", instances = ["ps08w1"], priority = "260", zone_id = "Z2IX59JMXPQ6BD" }
    "ps09.mobilehealthconsumer.com"   = { tg = "ps09w-all-TG", instances = ["ps09w2", "ps09w3"], priority = "270", zone_id = "Z2IX59JMXPQ6BD" }
    "ps09w1.mobilehealthconsumer.com"   = { tg = "ps09w1-TG", instances = ["ps09w1"], priority = "280", zone_id = "Z2IX59JMXPQ6BD" }
    "ps10.mobilehealthconsumer.com"   = { tg = "ps10w-all-TG", instances = ["ps10w2", "ps10w3"], priority = "290", zone_id = "Z2IX59JMXPQ6BD" }
    "ps10w1.mobilehealthconsumer.com"   = { tg = "ps10w1-TG", instances = ["ps10w1"], priority = "300", zone_id = "Z2IX59JMXPQ6BD" }
    "ps11.mobilehealthconsumer.com"   = { tg = "ps11w-all-TG", instances = ["ps11w2", "ps11w3"], priority = "310", zone_id = "Z2IX59JMXPQ6BD" }
    "ps11w1.mobilehealthconsumer.com"   = { tg = "ps11w1-TG", instances = ["ps11w1"], priority = "320", zone_id = "Z2IX59JMXPQ6BD" }
    "ps12.mobilehealthconsumer.com"   = { tg = "ps12w-all-TG", instances = ["ps12w2", "ps12w3"], priority = "330", zone_id = "Z2IX59JMXPQ6BD" }
    "ps12w1.mobilehealthconsumer.com"   = { tg = "ps12w1-TG", instances = ["ps12w1"], priority = "340", zone_id = "Z2IX59JMXPQ6BD" }
    "ps14.mobilehealthconsumer.com"   = { tg = "ps14w-all-TG", instances = ["ps14w2", "ps14w3"], priority = "330", zone_id = "Z2IX59JMXPQ6BD" }
    "ps14w1.mobilehealthconsumer.com"   = { tg = "ps14w1-TG", instances = ["ps14w1"], priority = "340", zone_id = "Z2IX59JMXPQ6BD" }
  }
  cloudfront_alias = ["mobilehealthconsumer.com", "www.mobilehealthconsumer.com"]
  alt_apex_records = ["engagementpoint.com"]
  skip_list        = ["alightwell.com", "www.alightwell.com", "ps07.alightwell.com"]
  concat_lists     = concat(local.cloudfront_alias, local.skip_list, local.alt_apex_records)
  shard_root       = ["plog.mobilehealthconsumer.com", "ps01.mobilehealthconsumer.com", "ps02.mobilehealthconsumer.com", "ps03.mobilehealthconsumer.com", "ps04.mobilehealthconsumer.com", "ps05.mobilehealthconsumer.com", "ps06.mobilehealthconsumer.com", "ps07.mobilehealthconsumer.com", "ps08.mobilehealthconsumer.com", "ps09.mobilehealthconsumer.com", "ps10.mobilehealthconsumer.com", "ps11.mobilehealthconsumer.com", "ps12.mobilehealthconsumer.com"]

  direct_to_lb    = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.concat_lists, url) == false }
  cloudfront_urls = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
  apex_urls       = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.alt_apex_records, url) }
}

module "alb_hbr_prod" {
  source     = "../../../../../modules/alb_hbr"
  env        = "Production"
  subnet_env = "Prod"
  sg_env     = "Production"
  default_TG = "plogw-TG"
  secondary_alb_cert = [
    "engagementpoint.com",
    "*.alightwell.com"
  ]
  idle_timeout            = 4000
  alb_info                = local.alb_info
  r53_healthcheck_enabled = false
}

# This is what creates the cloudfront Alias list, for the root domain, and www, and for every shard list
module "cloudfront" {
  source         = "../../../../../modules/cloudfront"
  environment    = "Production"
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr_prod.lb.dns_name
  acm_cert_arn   = data.aws_acm_certificate.main.arn
  wp_site_url    = "mobilehealth44.wpengine.com"
}

# These are the two records created, one to the load balancer, one to the cloudfront
resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_prod.lb.dns_name]
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

resource "aws_route53_record" "apex" {
  for_each = local.apex_urls
  zone_id  = each.value
  name     = each.key
  type     = "A"
  alias {
    name                   = module.alb_hbr_prod.lb.dns_name
    zone_id                = module.alb_hbr_prod.lb.zone_id
    evaluate_target_health = false
  }
}
