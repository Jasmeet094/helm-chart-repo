locals {
  environment = "op"
  key_name    = "MHC-Matt"
  general_sg  = "sg-12667d75"
  vpc_id      = "vpc-0b10526e"

  shards = toset(["log", "s01"])

  shards_with_new_volumes = ["log", "s01", "s02"]

  # Override default AMI
  # amis = { 
  #   "log" = {
  #     "w"  = ["ami-0ccde452fec6ccc14", "ami-0476347c242f1bd95"]
  #     "db" = "ami-012a4b756c3f727f7"
  #   }
  #   "s01" = {
  #     "w"  = ["ami-005a7fd8a00264cea", "ami-029d72374869efa4e"]
  #     "db" = "ami-08692096986b14182"
  #   }
  #   "s02" = {
  #     "w"  = ["ami-031b1f872d286c170", "ami-031b1f872d286c170"]
  #     "db" = "ami-031b1f872d286c170"
  #   }
  # }


 # ToDo: Make this be dynamic
  alb_info = {
    "op.mobilehealthconsumer.com"      = { tg = "oplogw-TG", instances = ["oplogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "oplogw1.mobilehealthconsumer.com" = { tg = "oplogw1-TG", instances = ["oplogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "ops01w1.mobilehealthconsumer.com" = { tg = "ops01w1-TG", instances = ["ops01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "oplog.mobilehealthconsumer.com"   = { tg = "oplogw-TG", instances = ["oplog*"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "ops01.mobilehealthconsumer.com"   = { tg = "ops01-TG", instances = ["ops01*"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    }
  cloudfront_alias = ["op.mobilehealthconsumer.com"]
  shard_root       = ["oplog.mobilehealthconsumer.com", "ops01.mobilehealthconsumer.com"]

  tag_backup = local.environment == "p" ? "mhc-prod-backup" : "mhc-nonprod-backup"
  tag_operations = local.environment == "p" ? jsonencode(tomap({"HIPPA" ="T"})) : ""

  # tags = {
  #   "Environment"    = local.environment
  #   (local.tag_backup) = "true"
  #   "Operations"     = local.tag_operations
  #   "Terraform"      = "True"
  #   "Ansible"        = "True"
  # }
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
  # tags               = local.tags
  shard_type         = each.key
  #ami_web            = lookup(lookup(local.amis, each.key, ""), "w", "") # toDo: this should be a list
  #ami_db             = lookup(lookup(local.amis, each.key, ""), "db", "")
  base_name          = "${local.environment}${each.key}"
  shard              = each.key
  create_secondary_volumes = contains(local.shards_with_new_volumes, each.key)
  vpc_id             = local.vpc_id
}


locals {
  direct_to_lb    = { for url, tginopancesmap in local.alb_info : url => tginopancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls = { for url, tginopancesmap in local.alb_info : url => tginopancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr" {
  source     = "../../../../modules/alb_hbr"
  env        = local.environment
  subnet_env = "QA" # ToDo: Make this dynamic when we have more subnets
  sg_env     = local.environment
  default_TG = "oplogw-TG" # ToDo: Make this dynam
  alb_info   = local.alb_info
  enable_deletion_protection = false
  depends_on = [module.shards, module.shard_env]
  vpc_id     = local.vpc_id
  create_waf_v2 = true
}

module "cloudfront" {
  providers = {
    aws = aws
    aws.cloudfront = aws.us-east-1
   }
  source         = "../../../../modules/cloudfront"
  environment    = upper(local.environment)
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr.lb.dns_name
  acm_cert_arn   = "arn:aws:acm:us-east-1:913835907225:certificate/31cbc5a7-ebd6-4bfe-bf42-69722ece2de8"
  wp_site_url    = "mobilehealth44.wpengine.com"
  create_waf_v2 = true
}

resource "aws_route53_record" "dynamic" {
  for_each        = local.direct_to_lb
  zone_id         = each.value
  name            = each.key
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_hbr.lb.dns_name]
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