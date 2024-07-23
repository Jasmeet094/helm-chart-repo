locals {
  alb_info_int = {
    "monitoring.mobilehealthconsumer.com"      = { tg = "SSMON-TG", instances = ["ssmon01"], priority = "10", health_check = "/", port = 443, protocol = "HTTPS" }
    "jetbrains.mobilehealthconsumer.com"       = { tg = "SSJET-TG", instances = ["ssjet01"], priority = "20", health_check = "/licenseServer/login.action", port = 80, protocol = "HTTP" }
    "nessus.mobilehealthconsumer.com"          = { tg = "NESSUS-TG", instances = ["Nessus-scanner"], priority = "60", health_check = "/", port = 8834, protocol = "HTTPS" }
  }

  alb_info_ext = {
    "cfr.mobilehealthconsumer.com"  = { tg = "CFR-TG", instances = ["sscfr01"], priority = "10", health_check = "/", port = 443, protocol = "HTTPS" }
    "dev2.mobilehealthconsumer.com" = { tg = "SSDEV2-TG", instances = ["ssdev02"], priority = "20", health_check = "/redmine/login", port = 443, protocol = "HTTPS" }
  }
}

module "alb_hbr_ss_int" {
  source      = "../../../../../modules/alb_ss"
  env         = "SS"
  subnet_env  = "ShareServices"
  sg_env      = "SS"
  internal_lb = true
  alb_info    = local.alb_info_int
}


resource "aws_route53_record" "dynamic" {
  for_each = local.alb_info_int
  zone_id  = "Z2IX59JMXPQ6BD"
  name     = each.key
  type     = "A"
  alias {
    name                   = module.alb_hbr_ss_int.lb.dns_name
    zone_id                = module.alb_hbr_ss_int.lb.zone_id
    evaluate_target_health = false
  }
  allow_overwrite = true
}

module "alb_hbr_ss_ext" {
  source      = "../../../../../modules/alb_ss"
  env         = "SS"
  subnet_env  = "ShareServices"
  sg_env      = "SS"
  internal_lb = false
  alb_info    = local.alb_info_ext
}


resource "aws_route53_record" "dynamic_ext" {
  for_each = local.alb_info_ext
  zone_id  = "Z2IX59JMXPQ6BD"
  name     = each.key
  type     = "A"
  alias {
    name                   = module.alb_hbr_ss_ext.lb.dns_name
    zone_id                = module.alb_hbr_ss_ext.lb.zone_id
    evaluate_target_health = false
  }
  allow_overwrite = true
}
