data "aws_route53_zone" "mhc" {
  name = "${var.root_domain}."
}

data "aws_lb" "target" {
  arn = "${var.lb_arn}"
}
