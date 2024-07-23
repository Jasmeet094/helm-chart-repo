resource "aws_security_group" "web" {
  name_prefix            = "${var.environment}_web"
  description            = "${var.environment} Web SG"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true
  tags                   = { "Name" = "Web-${var.environment}" }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web-i-https-t" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.lb.id
  description              = "https to LB"
}


resource "aws_security_group_rule" "web-i-https-t-monitoring" {
  count = var.monitoring_sg_id == "" ? 0 : 1

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = var.monitoring_sg_id
  description              = "https to web from monitoring"
}

resource "aws_security_group_rule" "web-i-http-t-monitoring" {
  count = var.monitoring_sg_id == "" ? 0 : 1

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = var.monitoring_sg_id
  description              = "https to web from monitoring"
}

resource "aws_security_group_rule" "web-i-http-t" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.lb.id
  description              = "http to web"
}

resource "aws_security_group_rule" "web-e-mongo-t" {
  type                     = "egress"
  from_port                = 27027
  to_port                  = 27027
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.db.id
  description              = "mongo outbound"
}

resource "aws_security_group_rule" "web-e-db-t" {
  type                     = "egress"
  from_port                = 6432
  to_port                  = 6432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.db.id
  description              = "postgres outbound"
}

resource "aws_security_group_rule" "web-e-http-t" {
  count             = var.enable_internet ? 1 : 0
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "http outbound"
}

resource "aws_security_group_rule" "web-e-https-t" {
  count             = var.enable_internet ? 1 : 0
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "https outbound"
}
resource "aws_security_group_rule" "web-e-ntp-t" {
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ntp outbound"
}
resource "aws_security_group_rule" "web-e-ntp-u" {
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ntp outbound"
}

resource "aws_security_group_rule" "web-e-dns-t" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "dns outbound"
}

resource "aws_security_group_rule" "web-e-dns-u" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "dns outbound"
}
resource "aws_security_group_rule" "web-e-self" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.web.id
  self              = true
  description       = "all outbound to itself"
}

resource "aws_security_group_rule" "web-i-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.web.id
  self              = true
  description       = "all outbound to itself"
}
