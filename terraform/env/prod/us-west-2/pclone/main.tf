locals {
  environment = "pclone"
  key_name    = "MHC-Matt"
  general_sg  = "sg-12667d75"
  vpc_id      = "vpc-0b10526e"

  shards = toset(["log", "s01", "s02"])

  # Override default AMI
  amis = { "log" = {
    "w"  = ["ami-0112475cbfe71e58e"]
    "db" = "ami-0c270756e1a29ad83"
    }
    "s01" = {
      "w"  = ["ami-0c7f5436d2f4b70e2"]
      "db" = "ami-03e6fa019ecc7c084"
    }
    "s02" = {
      "w"  = ["ami-094da62bf0f0663e9"]
      "db" = "ami-0eb8af8902dc62718"
    }}


 # ToDo: Make this be dynamic
  alb_info = {
    "${local.environment}.mobilehealthconsumer.com"      = { tg = "${local.environment}logw-TG", instances = ["${local.environment}logw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}logw1.mobilehealthconsumer.com" = { tg = "${local.environment}logw1-TG", instances = ["${local.environment}logw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}s01w1.mobilehealthconsumer.com" = { tg = "${local.environment}s01w1-TG", instances = ["${local.environment}s01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}s02w1.mobilehealthconsumer.com" = { tg = "${local.environment}s02w1-TG", instances = ["${local.environment}s02w1"], priority = "40", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}log.mobilehealthconsumer.com"   = { tg = "${local.environment}logw-TG", instances = ["${local.environment}logw1"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}s01.mobilehealthconsumer.com"   = { tg = "${local.environment}s01w-all-TG", instances = ["${local.environment}s01w*"], priority = "80", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}s02.mobilehealthconsumer.com"   = { tg = "${local.environment}s02w-all-TG", instances = ["${local.environment}s02w*"], priority = "90", zone_id = "Z2IX59JMXPQ6BD" }
    "${local.environment}.mobhealthinternal.com"         = { tg = "${local.environment}logw-TG", instances = ["${local.environment}logw*"], priority = "130", zone_id = "Z1G1UDKK3Y11OQ" }
  }
  cloudfront_alias = ["${local.environment}.mobilehealthconsumer.com"]
  shard_root       = ["${local.environment}log.mobilehealthconsumer.com", "${local.environment}s01.mobilehealthconsumer.com", "${local.environment}s02.mobilehealthconsumer.com"]

  # tag_operations = jsonencode(tomap({"HIPPA"= "T"})) 

  tags = {
    "Environment"    = local.environment
    "Backup"         = "NonProd"
    "Terraform"      = "True"
    "Ansible"        = "True"
  }
}

module "shard_env" {
  source      = "../../../../modules/shard_env/"
  environment = local.environment
  vpc_id      = local.vpc_id
  enable_internet = false
}

module "shards" {
  for_each           = local.shards
  vpc_id             = local.vpc_id
  source             = "../../../../modules/shard/"
  web_security_group = [module.shard_env.web.id, local.general_sg]
  db_security_group  = [module.shard_env.db.id, local.general_sg]
  key_name           = local.key_name
  shard              = each.key
  shard_type         = each.key
  ami_web            = lookup(lookup(local.amis, each.key, ""), "w", "") # toDo: this should be a list
  ami_db             = lookup(lookup(local.amis, each.key, ""), "db", "")
  base_name          = "${local.environment}${each.key}"
  subnet_name        = "Production*"
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
  default_TG = "${local.environment}logw-TG" # ToDo: Make this dynamic
  alb_info   = local.alb_info
  enable_deletion_protection = false

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