#output "alb_dns" {
#  value = "${aws_alb.lb.dns_name}"
#}

#output "alb_zone" {
#  value = "${aws_alb.lb.zone_id}"
#}

output "web_public_ip" {
  value = "${aws_eip.eip.public_ip}"
}

output "web_private_ip" {
  value = "${aws_eip.eip.private_ip}"
}

output "db_public_ip" {
  value = "${module.db.public_ip}"
}

output "db_private_ip" {
  value = "${module.db.private_ip}"
}
