

# resource "aws_efs_file_system" "efs_data_shard" {
#   performance_mode = "generalPurpose"
#   encrypted        = true
#   kms_key_id       = var.efs_kms
#   tags = {"Name": "${var.env}${var.shard}efs01"}
# }

# # should be turned into foreach
# resource "aws_efs_mount_target" "efs_shard" {
#   count           = length(var.subnets)
#   file_system_id  = aws_efs_file_system.efs_data_shard.id
#   subnet_id       = element(var.subnets, count.index)
#   security_groups = [aws_security_group.efs.id]
# }

# resource "aws_route53_record" "shard" {
#   zone_id = var.r53_hosted_zone
#   name    = "${var.env}${var.shard}-efs.mobilehealthconsumer.com"
#   type    = "CNAME"
#   ttl     = "60"
#   records = [aws_efs_file_system.efs_data.dns_name]
# }

# output "r53_dns_shard" {
#   value = aws_route53_record.shard.fqdn
# }