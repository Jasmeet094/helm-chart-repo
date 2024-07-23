
resource "aws_security_group" "db" {
  name_prefix            = "${var.environment}_db"
  description            = "${var.environment} DB SG"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true
  tags                   = { "Name" = "DB-${var.environment}" }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "db-i-mongo-t" {
  type                     = "ingress"
  from_port                = 27027
  to_port                  = 27027
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.web.id
  description              = "mongo inbound"
}

resource "aws_security_group_rule" "db-i-db-t" {
  type                     = "ingress"
  from_port                = 6432
  to_port                  = 6432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.web.id
  description              = "postgres inbound"
}


resource "aws_security_group_rule" "db-i-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.db.id
  self              = true
  description       = "all outbound to itself"
}
resource "aws_security_group_rule" "db-e-self" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.db.id
  self              = true
  description       = "all outbound to itself"
}



########################
### General OS stuff ###
########################

resource "aws_security_group_rule" "db-e-http-t" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "http outbound"
}

resource "aws_security_group_rule" "db-e-https-t" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "https outbound"
}
resource "aws_security_group_rule" "db-e-ntp-t" {
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ntp outbound"
}
resource "aws_security_group_rule" "db-e-ntp-u" {
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ntp outbound"
}