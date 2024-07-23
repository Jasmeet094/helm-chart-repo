# This locals shit is all Brad, its awesome, but if you ever need help figuring out whats going on, call Brad
locals {
  tg_all_instances_map      = { for url, tginstancesmap in var.alb_info : tginstancesmap["tg"] => tginstancesmap["instances"]... }
  tg_flat_instances_map     = { for targetgroupname, instancespatternlists in local.tg_all_instances_map : targetgroupname => flatten(instancespatternlists) }
  tg_distinct_instances_map = { for targetgroupname, instancespatternlists in local.tg_flat_instances_map : targetgroupname => distinct(instancespatternlists) }
  # if this was turned into a set instead of a list, this may fix the issue here
  #  sets didn't exist when this was originally listed
  #  This is why we have to manually attach instances into ALBs for now
  # Brad would be a great resource here to help
  tg_attachments_list_all = [
    for targetgroupname, instancepatternlist in local.tg_distinct_instances_map : [
      for instancepattern in instancepatternlist : {
        for instanceid in data.aws_instances.test[replace(instancepattern, "*", "")].ids : targetgroupname => instanceid...
      }
    ]
  ]
  tg_attachments_list_presquash = flatten(local.tg_attachments_list_all)

  tg_attachments_list_expanded = [
    for tg_attachment_map in local.tg_attachments_list_presquash : [
      for targetgroupname, instanceid_list in tg_attachment_map : [
        for instanceid in instanceid_list : tomap({ targetgroupname = instanceid })
      ]
    ]
  ]

  tg_attachments_list = flatten(flatten(local.tg_attachments_list_expanded))


  instance_list_all      = [for url, tginstancesmap in var.alb_info : tginstancesmap["instances"]]
  instance_list_distinct = distinct(flatten(local.instance_list_all))
  instance_map           = { for instancepattern in local.instance_list_distinct : replace(instancepattern, "*", "") => instancepattern }

  target_group_list_distinct = distinct([for url, tginstancesmap in var.alb_info : tginstancesmap["tg"]])
  target_group_map           = { for targetgroupname in local.target_group_list_distinct : targetgroupname => targetgroupname }
}

data "aws_region" "current" {}

resource "aws_lb" "mhc_alb" {
  name                       = "${var.env}-ALB1"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = data.aws_security_groups.alb_sg.ids
  subnets                    = data.aws_subnet_ids.alb_subnets.ids
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout

  dynamic "access_logs" {
    for_each = !(var.alb_logs_bucket != "mhc-logs" && data.aws_region.current.name == "us-east-1") ? toset(["one"]) : []
    content {
      bucket  = var.alb_logs_bucket
      prefix  = lower(var.env)
      enabled = true
    }
  }

  tags = {
    Name = "${var.env}-ALB"
  }
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.mhc_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.mhc_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = data.aws_acm_certificate.alb_cert_primary.arn

  default_action {
    type = "forward"
    #target_group_arn	= aws_lb_target_group.incoming.arn
    target_group_arn = aws_lb_target_group.ALB_TGs[var.default_TG].arn
  }
}

resource "aws_lb_listener_certificate" "secondary_alb_cert" {
  count           = length(var.secondary_alb_cert)
  listener_arn    = aws_lb_listener.front_end_https.arn
  certificate_arn = data.aws_acm_certificate.alb_cert_secondary[count.index].arn
}

resource "aws_lb_target_group" "ALB_TGs" {
  for_each = local.target_group_map
  name     = each.key
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  # preserve_client_ip = true

  health_check {
    protocol            = "HTTPS"
    healthy_threshold   = 5
    interval            = 30
    path                = "/api/v3/getLoginServer/"
    timeout             = 20
    unhealthy_threshold = 5
    matcher             = "200,301,302"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 600
    enabled         = true
  }

  # tags = {
  #   Environment = lower(var.env) == "production" ? "p" : lower(var.env)
  # }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_cloudwatch_metric_alarm" "alb-hhc" {
  for_each            = var.alb_info
  alarm_name          = aws_lb_target_group.ALB_TGs[each.value["tg"]].name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Number of X unhealthy nodes in Target Group"
  treat_missing_data  = "breaching"
  # alarm_actions 	    = [ "arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c" ] 
  # ok_actions		      = [ "arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c" ]
  dimensions = {
    TargetGroup  = aws_lb_target_group.ALB_TGs[each.value["tg"]].arn_suffix
    LoadBalancer = aws_lb.mhc_alb.arn_suffix
  }
}

resource "aws_lb_listener_rule" "path_based" {
  for_each     = var.alb_info
  listener_arn = aws_lb_listener.front_end_https.arn
  priority     = each.value["priority"]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALB_TGs[each.value["tg"]].arn
    #target_group_arn	= aws_lb_target_group.ALB_TGs[each.key].arn
  }

  condition {
    host_header {
      values = [each.key]
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_health_check" "health_check" {
  for_each          = var.r53_healthcheck_enabled ? var.alb_info : {}
  fqdn              = each.key
  port              = 443
  resource_path     = length(regexall("www.*", each.key)) > 0 ? "/" : "/partners"
  failure_threshold = "5"
  request_interval  = "30"
  search_string     = length(regexall("www.*", each.key)) > 0 ? "Mobile" : "mobilehealthconsumer"
  type              = "HTTPS_STR_MATCH"
  measure_latency   = true
  # tags = {
  #   Environment = lower(var.env) == "production" ? "p" : lower(var.env)
  # }
}

#

# resource "aws_lb_target_group_attachment" "mhc_alb_attachments" {
#   count            = length(local.tg_attachments_list)
#   target_group_arn = aws_lb_target_group.ALB_TGs[keys(local.tg_attachments_list[count.index])[0]].arn
#   target_id        = values(local.tg_attachments_list[count.index])[0]
#   lifecycle {
#     ignore_changes = [
#       "*"
#     ]
#   }
# }

resource "aws_wafregional_web_acl_association" "mhc_waf" {
  count        = var.create_waf_v2 ? 0 : 1

  resource_arn = aws_lb.mhc_alb.arn
  web_acl_id   = data.aws_wafregional_web_acl.mhc_waf_acl[count.index].id
}


resource "aws_wafv2_web_acl_association" "v2" {
  count        = var.create_waf_v2 ? 1 : 0

  resource_arn = aws_lb.mhc_alb.arn
  web_acl_arn  = module.wafv2[count.index].web_acl.arn
}

module "wafv2" {
  count       = var.create_waf_v2 ? 1 : 0

  source      = "../wafv2"
  scope       = "REGIONAL"
  environment = var.env
}

output "lb" {
  value = aws_lb.mhc_alb
}

#### Debugging output
# output "aws_alb_tgs" {
#  value = aws_lb_target_group.ALB_TGs
# }

# output "aws_instances" {
#   value = data.sns.test
# }

# output "tg_all_instances_map" { value = local.tg_all_instances_map }
# output "tg_flat_instances_map" { value = local.tg_flat_instances_map }
# output "tg_distinct_instances_map" { value = local.tg_distinct_instances_map }
# output "tg_attachments_list_all" { value = local.tg_attachments_list_all }
# output "tg_attachments_list_all_length" { value = length(local.tg_attachments_list_all) }
# output "tg_attachments_list" { value = local.tg_attachments_list }
# output "tg_attachments_list_expanded" { value = local.tg_attachments_list_expanded }
# output "tg_attachments_list_length" { value = length(local.tg_attachments_list) }
# output "instance_list_all" { value = local.instance_list_all }
# output "instance_list_distinct" { value = local.instance_list_distinct }
# output "instance_map" { value = local.instance_map }
# output "target_group_list_distinct" { value = local.target_group_list_distinct }
# output "target_group_map" { value = local.target_group_map }


# # output "test" {
# #   value = data.aws_iam_server_certificate.alb_cert_primary
# # }
