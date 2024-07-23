locals {
  dev = {
    "alc.mobilehealthconsumer.com"      = { tg = "alc-TG", instances = ["alc"], priority = "10", health_check = "/", port = 443, protocol = "HTTPS" }
    "ll3.mobilehealthconsumer.com"      = { tg = "ll3-TG", instances = ["ll3"], priority = "20", health_check = "/", port = 443, protocol = "HTTPS" }
    "cw3.mobilehealthconsumer.com"      = { tg = "cw3-TG", instances = ["cw3"], priority = "30", health_check = "/", port = 443, protocol = "HTTPS" }
    "aa3.mobilehealthconsumer.com"      = { tg = "aa3-TG", instances = ["aa3"], priority = "40", health_check = "/", port = 443, protocol = "HTTPS" }
    "lf3.mobilehealthconsumer.com"      = { tg = "lf3-TG", instances = ["lf3"], priority = "50", health_check = "/", port = 443, protocol = "HTTPS" }
    "lf3.mobilehealthconsumer.com"      = { tg = "kw3-TG", instances = ["kw3"], priority = "60", health_check = "/", port = 443, protocol = "HTTPS" }
    "kw3.mobilehealthconsumer.com"      = { tg = "kw3-TG", instances = ["alc3"], priority = "70", health_check = "/", port = 443, protocol = "HTTPS" }
    "sk3.mobilehealthconsumer.com"      = { tg = "sk3-TG", instances = ["sk3"], priority = "80", health_check = "/", port = 443, protocol = "HTTPS" }
    "lf.mobilehealthconsumer.com"       = { tg = "lf-TG", instances  = ["lf"], priority = "90", health_check = "/", port = 443, protocol = "HTTPS" }
  }
}

module "dev" {
  source      = "../../../../../modules/alb_ss"
  env         = "d"
  subnet_env  = "ShareServices"
  sg_env      = "QA"
  internal_lb = false
  alb_info    = local.dev
}


resource "aws_route53_record" "dynamic_ext" {
  for_each = local.dev
  zone_id  = "Z2IX59JMXPQ6BD"
  name     = each.key
  type     = "A"
  alias {
    name                   = module.dev.lb.dns_name
    zone_id                = module.dev.lb.zone_id
    evaluate_target_health = false
  }
  allow_overwrite = true
}
