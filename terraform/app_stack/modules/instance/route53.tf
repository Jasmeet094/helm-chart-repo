
# resource "aws_route53_record" "r53" {
#   zone_id = "${var.r53_zone_id}"
#   name    = "${var.env}${var.shard}${var.server}.${var.domain}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${var.eip == "" ? aws_instance.instance.public_ip : var.eip}"]
# }

# resource "aws_route53_record" "origin" {
#   zone_id = "${var.r53_zone_id}"
#   name    = "${var.env}${var.shard}${var.server}origin.${var.domain}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${var.eip == "" ? aws_instance.instance.public_ip : var.eip}"]
# }

resource "aws_route53_record" "pvt" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.env}${var.shard}${var.server}pvt.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.instance.private_ip}"]
}



# resource "aws_route53_record" "mobhealthinternal" {
#   zone_id = "${var.r53_private_zone_id}"
#   name    = "${var.env}${var.shard}${var.server}.mobhealthinternal.com"
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_instance.instance.private_ip}"]
# }
