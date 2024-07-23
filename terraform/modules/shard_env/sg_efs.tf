resource "aws_security_group" "efs" {
  count                  = var.enable_efs ? 1 : 0
  name_prefix            = "${var.environment}efs"
  description            = "${var.environment} EFS"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "efs_inbound" {
  count             = var.enable_efs ? 1 : 0
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.efs[0].id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block] # this should be locked down the sg
  description       = "EFS ingress"
}