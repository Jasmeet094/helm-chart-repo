resource "aws_route53_record" "efs" {
  count   = var.enable_efs ? 1 : 0
  zone_id = var.r53_hosted_zone
  name    = "${var.environment}efspvt.mobilehealthconsumer.com"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_efs_file_system.efs_data[0].dns_name]
}