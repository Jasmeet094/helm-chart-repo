resource "aws_route53_record" "waf" {
  zone_id = "${data.aws_route53_zone.mhc.zone_id}"
  name    = "${var.subdomain}.${var.root_domain}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.target.dns_name}"
    zone_id                = "${var.zone_id == "" ? data.aws_route53_zone.mhc.id : var.zone_id}"
    evaluate_target_health = false
  }

  # depends_on = ["data.external.wait"]

  # Use `terraform state rm aws_route53_record.waf` before destroy
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "additional" {
  count   = "${length(var.additional_aliases)}"
  zone_id = "${data.aws_route53_zone.mhc.zone_id}"
  name    = "${element(var.additional_aliases, count.index)}"
  type    = "A"
  alias {
    name                   = "${data.aws_lb.target.dns_name}"
    zone_id                = "${var.zone_id == "" ? data.aws_route53_zone.mhc.id : var.zone_id}"
    evaluate_target_health = false
  }
  # Use `terraform state rm aws_route53_record.waf` before destroy
  lifecycle {
    prevent_destroy = true
  }
}
