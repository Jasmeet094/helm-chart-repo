data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "efs" {
  name_prefix = var.env
  description = "${var.env} EFS"
  vpc_id      = var.vpc_id
}


resource "aws_security_group_rule" "efs_inbound" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.efs.id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block] # this should be locked down the sg
}
