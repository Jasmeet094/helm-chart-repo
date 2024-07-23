

resource "aws_security_group" "lb" {
  name_prefix            = "${var.environment}lb"
  description            = "${var.environment} LB SG"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true
  tags                   = { "Name" = "ELB-${var.environment}" }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "lb-i-http-t" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "http inbound"
}

resource "aws_security_group_rule" "lb-i-https-t" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "https inbound"
}

resource "aws_security_group_rule" "lb-e-https-t" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb.id
  source_security_group_id = aws_security_group.web.id
  description              = "https to web"
}

resource "aws_security_group_rule" "lb-e-http-t" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb.id
  source_security_group_id = aws_security_group.web.id
  description              = "http to web"
}