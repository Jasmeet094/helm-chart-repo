locals {
  environment = "bfog"
  key_name    = "MHC - Brian"

  shards = toset(["log", "s01"])

  #  This code can be improved upon to get more dynamic using local calls from the pclone example main.tf file

  # This exists to create a new volume for new web servers, for creatinga  brand new shard in a brand new environment
  # If this isn't commented out, this will run the contain on line 76
  # If you're not adding a new volume to a cloned creation, include all shards that need this code
  shards_with_new_volumes = ["log", "s01"]

  # Override default AMI
  # The purpose of this override code was done while QA was done to spin up st and sn envs, for cloning and environment
  # If you are not cloning, leave this commented out
  #  amis = { 
  #    "log" = {
  #      "w"  = ["ami-0ccde452fec6ccc14", "ami-0476347c242f1bd95"]
  #      "db" = "ami-012a4b756c3f727f7"
  #    }
  #    "s01" = {
  #      "w"  = ["ami-005a7fd8a00264cea", "ami-029d72374869efa4e"]
  #      "db" = "ami-08692096986b14182"
  #    }
  #   "s02" = {
  #      "w"  = ["ami-031b1f872d286c170", "ami-031b1f872d286c170"]
  #      "db" = "ami-031b1f872d286c170"
  #    }
  #  }


  # ToDo: Make this be dynamic
  # Zone ID is only added to allow for changing from mobilehealthconsumer.com to engagement dns
  # If we migrate to a newer version of terraform, we could use sets here, but then we would need to test it
  alb_info = {
    "bfog.mobilehealthconsumer.com"      = { tg = "bfoglogw-TG", instances = ["bfoglogw*"], priority = "10", zone_id = "Z2IX59JMXPQ6BD" }
    "bfoglogw1.mobilehealthconsumer.com" = { tg = "bfoglogw1-TG", instances = ["bfoglogw1"], priority = "20", zone_id = "Z2IX59JMXPQ6BD" }
    "bfogs01w1.mobilehealthconsumer.com" = { tg = "bfogs01w1-TG", instances = ["bfogs01w1"], priority = "30", zone_id = "Z2IX59JMXPQ6BD" }
    "bfoglog.mobilehealthconsumer.com"   = { tg = "bfoglogw-TG", instances = ["bfoglog*"], priority = "50", zone_id = "Z2IX59JMXPQ6BD" }
    "bfogs01.mobilehealthconsumer.com"   = { tg = "bfogs01-TG", instances = ["bfogs01*"], priority = "60", zone_id = "Z2IX59JMXPQ6BD" }
    "bfogs02.mobilehealthconsumer.com"   = { tg = "bfogs02-all-TG", instances = ["bfogs02w1"], priority = "70", zone_id = "Z2IX59JMXPQ6BD" }
    "bfogs02w1.mobilehealthconsumer.com" = { tg = "bfogs02-w1-TG", instances = ["bfogs02w2"], priority = "80", zone_id = "Z2IX59JMXPQ6BD" }
  }
  cloudfront_alias = ["bfog.mobilehealthconsumer.com"]
  shard_root       = ["bfoglog.mobilehealthconsumer.com", "bfogs01.mobilehealthconsumer.com"]

  tag_backup     = local.environment == "p" ? "mhc-prod-backup" : "mhc-nonprod-backup"
  tag_operations = local.environment == "p" ? jsonencode(tomap({ "HIPPA" = "T" })) : ""

  # tags = {
  #   "Environment"    = local.environment
  #   (local.tag_backup) = "true"
  #   "Operations"     = local.tag_operations
  #   "Terraform"      = "True"
  #   "Ansible"        = "True"
  # }
}

# This is where we'd create resources to enable redis/amazonMQ for the POCs, inside the module, with a flag on them until they're ready to be applied everywhere to all environments
# shard creates shard specific resources 
# shard_env creates environment specific resources

module "shard_env" {
  source           = "../../../../modules/shard_env/"
  environment      = local.environment
  vpc_id           = module.vpc.vpc.id
  monitoring_sg_id = ""
}

module "ec2_instance_profiles" {
  source      = "../../../../modules/iam"
  environment = local.environment
}

module "shards" {
  for_each           = local.shards
  source             = "../../../../modules/shard/"
  web_security_group = [module.shard_env.web.id, module.vpc.default_security_group.id]
  vpc_id             = module.vpc.vpc.id
  db_security_group  = [module.shard_env.db.id, module.vpc.default_security_group.id]
  key_name           = local.key_name
  # tags               = local.tags
  shard_type = each.key
  #  ami_web            = lookup(lookup(local.amis, each.key, ""), "w", "") # toDo: this should be a list
  #  ami_db             = lookup(lookup(local.amis, each.key, ""), "db", "")
  base_name = "${local.environment}${each.key}"
  shard     = each.key
  # This is the if statement that is called upon and triggered by code on line 14
  create_secondary_volumes = contains(local.shards_with_new_volumes, each.key)
  web_instance_profile     = module.ec2_instance_profiles.web_server_profile
  db_instance_profile      = module.ec2_instance_profiles.db_server_profile

  ami_web     = ["ami-0b5bdd2aabbede4ca"]
  ami_db      = "ami-0b5bdd2aabbede4ca"
  subnet_id   = "subnet-02fc52f0d2ae0e61e"
  kms_default = "arn:aws:kms:eu-central-1:913835907225:key/mrk-dd6f956d9e994e6a8422a81200cf9761"
}

###### TODO
  # module.shards["log"].aws_instance.web[0] will be updated in-place
  # ~ resource "aws_instance" "web" {
  #       id                                   = "i-021baa8c20051765a"
  #       tags                                 = {
  #           "Name"  = "bfoglogw1"
  #           "Role"  = "Admin"
  #           "Shard" = "log"
  #       }
  #     ~ volume_tags                          = {
  #         - "Ansible"            = "True" -> null
  #         - "Environment"        = "bfog" -> null
  #         - "Name"               = "bfoglogw1-data" -> null
  #         - "Terraform"          = "True" -> null
  #         - "mhc-nonprod-backup" = "true" -> null
  #           # (2 unchanged elements hidden)
  #       }
  #       # (33 unchanged attributes hidden)




locals {
  direct_to_lb    = { for url, tginbfogancesmap in local.alb_info : url => tginbfogancesmap["zone_id"] if contains(local.cloudfront_alias, url) == false }
  cloudfront_urls = { for url, tginbfogancesmap in local.alb_info : url => tginbfogancesmap["zone_id"] if contains(local.cloudfront_alias, url) }
}

module "alb_hbr" {
  source                     = "../../../../modules/alb_hbr"
  env                        = local.environment
  subnet_env                 = "NonProduction" # ToDo: Make this dynamic when we have more subnets
  sg_env                     = local.environment
  default_TG                 = "bfoglogw-TG" # ToDo: Make this dynam
  alb_info                   = local.alb_info
  enable_deletion_protection = false
  vpc_id                     = module.vpc.vpc.id
  create_waf_v2              = true
  # secondary_alb_cert = [
  #   "qn.engagementpoint.com"
  # ]
  depends_on = [module.shards, module.shard_env]
}

#  This just shows some changes to the console for some testing changes
# output "test" {
#   value = module.alb_hbr
# }

module "cloudfront" {
  source         = "../../../../modules/cloudfront"
  environment    = upper(local.environment)
  domain_names   = concat(local.cloudfront_alias, local.shard_root)
  lb_domain_name = module.alb_hbr.lb.dns_name
  acm_cert_arn   = "arn:aws:acm:us-east-1:913835907225:certificate/31cbc5a7-ebd6-4bfe-bf42-69722ece2de8"
  wp_site_url    = "mobilehealth44.wpengine.com"
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

resource "aws_route53_record" "root" {
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
