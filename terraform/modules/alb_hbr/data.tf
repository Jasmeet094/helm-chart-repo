
data "aws_caller_identity" "mhc_prod" {}

data "aws_iam_server_certificate" "alb_cert_primary" {
  name   = "wildcard-jan2018-mar2021"
  latest = true
}

data "aws_acm_certificate" "alb_cert_primary" {
  domain      = var.primary_alb_cert
  statuses    = ["ISSUED"]
  most_recent = true
  types = ["IMPORTED"]
}

data "aws_acm_certificate" "alb_cert_secondary" {
  count = length(var.secondary_alb_cert)

  domain      = var.secondary_alb_cert[count.index]
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_security_groups" "alb_sg" {
  tags = {
    Name        = "ELB-${var.sg_env}"
    Environment = var.env
  }
}

#Why is there an ENV and Environment tag? this is no good
data "aws_subnet_ids" "alb_subnets" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:ENV"
    values = [var.subnet_env]
  }
}

data "aws_instances" "test" {
  for_each = local.instance_map

  filter {
    name   = "tag:Name"
    values = [each.value]
  }

  instance_state_names = ["running", "stopped"]
}

data "aws_wafregional_web_acl" "mhc_waf_acl" {
  count = var.create_waf_v2 ? 0 : 1
  name = "generic-owasp-acl"
}