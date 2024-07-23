data "aws_caller_identity" "mhc_prod" {}

data "aws_vpc" "mhc_prod_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MHCVPCv1"]
  }
}

# data "aws_iam_server_certificate" "alb_cert_primary" {
#   name   = "wildcard-jan2018-mar2021"
#   latest = true
# }

data "aws_acm_certificate" "alb_cert_primary" {
  domain      = var.primary_alb_cert
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_subnet_ids" "alb_subnets" {
  vpc_id = data.aws_vpc.mhc_prod_vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_env}-*"]
  }
}

data "aws_instances" "test" {
  for_each = var.alb_info

  filter {
    name   = "tag:Name"
    values = each.value["instances"]
  }

  instance_state_names = ["running", "stopped"]
}

data "aws_wafregional_web_acl" "mhc_waf_acl" {
  name = "generic-owasp-acl"
}

resource "aws_lb" "mhc_alb" {
  name                       = "${var.env}-${var.internal_lb ? "INT" : "EXT"}-ALB"
  internal                   = var.internal_lb
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = data.aws_subnet_ids.alb_subnets.ids
  enable_deletion_protection = true
  idle_timeout               = var.idle_timeout

  access_logs {
    bucket  = var.alb_logs_bucket
    prefix  = lower(var.env)
    enabled = true
  }

  tags = {
    Environment = lower(var.env) == "production" ? "p" : lower(var.env)
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
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = data.aws_acm_certificate.alb_cert_primary.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "ALB_TGs" {
  for_each = var.alb_info
  name     = "${each.value["tg"]}-${var.internal_lb ? "INT" : "EXT"}"
  port     = each.value["port"]
  protocol = each.value["protocol"]
  vpc_id   = data.aws_vpc.mhc_prod_vpc.id

  health_check {
    protocol            = each.value["protocol"]
    healthy_threshold   = 2
    interval            = 10
    path                = each.value["health_check"]
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = "200,301,302,403"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 600
    enabled         = false
  }

  tags = {
    Environment = lower(var.env)
  }
  lifecycle {
  create_before_destroy = true
}
}

resource "aws_lb_listener_rule" "path_based" {
  for_each     = var.alb_info
  listener_arn = aws_lb_listener.front_end_https.arn
  priority     = each.value["priority"]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALB_TGs[each.key].arn
  }

  condition {
    host_header {
      values = [each.key]
    }
  }
}

# This will only function if each URL in the map only has 1 instance tied to it.
resource "aws_lb_target_group_attachment" "mhc_alb_attachments" {
  for_each = var.alb_info
  target_group_arn = aws_lb_target_group.ALB_TGs[each.key].arn
  target_id        = data.aws_instances.test[each.key].ids[0]
}

resource "aws_wafregional_web_acl_association" "mhc_waf" {
  resource_arn = aws_lb.mhc_alb.arn
  web_acl_id   = data.aws_wafregional_web_acl.mhc_waf_acl.id
}

resource "aws_security_group" "alb" {
  name_prefix = "ALB-${var.env}-${var.internal_lb ? "INT" : "EXT"}-"
  description = "Allow 443 and 80 to the ALB"
  vpc_id      = data.aws_vpc.mhc_prod_vpc.id
  tags = {
    Environment = lower(var.env)
  }
  lifecycle {
  create_before_destroy = true
}
}

resource "aws_security_group" "alb_instances" {
  name_prefix = "ALB-instances-${var.env}-${var.internal_lb ? "INT" : "EXT"}-"
  description = "Allow 443 and 80 to instances behind ALB"
  vpc_id      = data.aws_vpc.mhc_prod_vpc.id
  tags = {
    Environment = lower(var.env)
  }
  lifecycle {
  create_before_destroy = true
}
}

resource "aws_security_group_rule" "alb_ingress_80" {
  description       = "HTTP to ALB"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = var.internal_lb ? [data.aws_vpc.mhc_prod_vpc.cidr_block] : ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_ingress_443" {
  description       = "HTTPS to ALB"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = var.internal_lb ? [data.aws_vpc.mhc_prod_vpc.cidr_block] : ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_80" {
  description              = "HTTP from ALB to instances"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.alb_instances.id
}

resource "aws_security_group_rule" "alb_egress_443" {
  description              = "HTTPS from ALB to instances"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.alb_instances.id
}

resource "aws_security_group_rule" "alb_egress_8834" {
  description              = "HTTPS from ALB to instances"
  type                     = "egress"
  from_port                = 8834
  to_port                  = 8834
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.alb_instances.id
}


resource "aws_security_group_rule" "instances_80" {
  description              = "HTTP ingress from ALB"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.alb_instances.id
}

resource "aws_security_group_rule" "instances_443" {
  description              = "HTTPS ingress from ALB"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.alb_instances.id
}

resource "aws_security_group_rule" "instances_8834" {
  description              = "HTTPS ingress from ALB"
  type                     = "ingress"
  from_port                = 8834
  to_port                  = 8834
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.alb_instances.id
}

#output "aws_alb_tgs" {
#  value = aws_lb_target_group.ALB_TGs
#}

# output "aws_instances" {
#   value = data.aws_instances.test
# }

output "lb" {
  value = aws_lb.mhc_alb
}