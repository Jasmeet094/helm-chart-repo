resource "aws_efs_file_system" "efs_data" {
  count            = var.enable_efs ? 1 : 0
  performance_mode = "generalPurpose"
  encrypted        = true
  kms_key_id       = var.efs_kms
}

# should be turned into foreach
resource "aws_efs_mount_target" "efs" {
  count           = var.enable_efs ? length(data.aws_subnets.selected.ids) : 0
  file_system_id  = aws_efs_file_system.efs_data[0].id
  subnet_id       = element(data.aws_subnets.selected.ids, count.index)
  security_groups = [aws_security_group.efs[0].id]
  lifecycle {
    create_before_destroy = true
  }
}

