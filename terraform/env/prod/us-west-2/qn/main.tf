locals {
  environment = "qn"
  key_name    = "MHC-Matt"
  general_sg  = "sg-12667d75"
  vpc_id      = "vpc-0b10526e"

  shards = toset(["log", "s01", "s02", "s03", "s04"])

  # Override default AMI
  amis = { "log" = {
    "w"  = ["ami-0be79e7893439752a"]
    "db" = "ami-0cd127b2411aa0495"
    }
    "s01" = {
      "w"  = ["ami-0706e0944719e825a"]
      "db" = "ami-0cc698d72b8d50da3"
    }
    "s02" = {
      "w"  = ["ami-02800e1348a894572"]
      "db" = "ami-08c20cce286b5851c"
    }
    "s03" = {
      "w"  =[ "ami-0b4433efe6be374ec"]
      "db" = "ami-0e75ecf2b85ed27f9"
    }
    "s04" = {
      "w"  = ["ami-075afd8b709ae22a1"]
      "db" = "ami-0160c002d05324226"
  }}


 # ToDo: Make this be dynamic
  alb_info = {
    "qn.mobilehealthconsumer.com"      = { tg = "qnlogw-TG", instances = ["qnlogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "qnlogw1.mobilehealthconsumer.com" = { tg = "qnlogw1-TG", instances = ["qnlogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "qns01w1.mobilehealthconsumer.com" = { tg = "qns01w1-TG", instances = ["qns01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "qns02w1.mobilehealthconsumer.com" = { tg = "qns02w1-TG", instances = ["qns02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "qns03w1.mobilehealthconsumer.com" = { tg = "qns03w1-TG", instances = ["qns03w1"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "qns04w1.mobilehealthconsumer.com" = { tg = "qns04w1-TG", instances = ["qns04w1"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "qnlog.mobilehealthconsumer.com"   = { tg = "qnlogw-TG", instances = ["qnlogw1"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
    "qns01.mobilehealthconsumer.com"   = { tg = "qns01w-all-TG", instances = ["qns01w*"], priority = "80", zone_id = "Z2IX59JMXPQ6BD" }
    "qns02.mobilehealthconsumer.com"   = { tg = "qns02w-all-TG", instances = ["qns02w*"], priority = "90", zone_id = "Z2IX59JMXPQ6BD" }
    "qns03.mobilehealthconsumer.com"   = { tg = "qns03w-all-TG", instances = ["qns03w*"], priority = "100", zone_id = "Z2IX59JMXPQ6BD" }
    "qns04.mobilehealthconsumer.com"   = { tg = "qns04w-all-TG", instances = ["qns04w*"], priority = "110", zone_id = "Z2IX59JMXPQ6BD" }
    "qns04.mobhealthinternal.com"      = { tg = "qns04w-all-TG", instances = ["qns04w*"], priority = "120", zone_id = "Z1G1UDKK3Y11OQ" }
    "qn.mobhealthinternal.com"         = { tg = "qnlogw-TG", instances = ["qnlogw*"], priority = "130", zone_id = "Z1G1UDKK3Y11OQ" }
    # "qn.engagementpoint.com"           = { tg = "bscqnw1-TG", instances = ["bscqnw1"], priority = "160", zone_id = "Z011593229BAR9FZ8P3JN" }
  }
  cloudfront_alias = ["qn.mobilehealthconsumer.com"]
  shard_root       = ["qnlog.mobilehealthconsumer.com", "qns01.mobilehealthconsumer.com", "qns02.mobilehealthconsumer.com", "qns03.mobilehealthconsumer.com", "qns04.mobilehealthconsumer.com"]




  tag_backup = local.environment == "p" ? "mhc-prod-backup" : "mhc-nonprod-backup"
  tag_operations = local.environment == "p" ? jsonencode(map("HIPPA", "T")) : ""

  tags = {
    "Environment"    = local.environment
    (local.tag_backup) = "true"
    "Operations"     = local.tag_operations
    "Terraform"      = "True"
    "Ansible"        = "True"
  }
}

module "shard_env" {
  source      = "../../../../modules/shard_env/"
  environment = local.environment
  vpc_id      = local.vpc_id
}

module "shards" {
  for_each           = local.shards
  source             = "../../../../modules/shard/"
  web_security_group = [module.shard_env.web.id, local.general_sg]
  db_security_group  = [module.shard_env.db.id, local.general_sg]
  key_name           = local.key_name
  shard              = each.key
  shard_type         = each.key
  ami_web            = lookup(lookup(local.amis, each.key, ""), "w", "") # toDo: this should be a list
  ami_db             = lookup(lookup(local.amis, each.key, ""), "db", "")
  base_name          = "${local.environment}${each.key}"
  vpc_id             = local.vpc_id
}


locals {
  direct_to_lb    = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls = { for url, tginstancesmap in local.alb_info : url => tginstancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr_qn" {
  source     = "../../../../modules/alb_hbr"
  env        = local.environment
  subnet_env = "NonProduction" # ToDo: Make this dynamic
  sg_env     = local.environment
  default_TG = "qnlogw-TG" # ToDo: Make this dynam
  alb_info   = local.alb_info
  enable_deletion_protection = false
  # secondary_alb_cert = [
  #   "qn.engagementpoint.com"
  # ]
  depends_on = [module.shards, module.shard_env]
}

module "cloudfront" {
  source         = "../../../../modules/cloudfront"
  environment    = upper(local.environment)
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr_qn.lb.dns_name
  acm_cert_arn   = data.aws_acm_certificate.main.arn
  wp_site_url    = "mobilehealth44.wpengine.com"
}

resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr_qn.lb.dns_name]
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