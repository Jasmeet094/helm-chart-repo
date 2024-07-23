data "aws_region" "current" {}

data "template_file" "dashboard" {
  template = "${file("${path.module}/templates/cloudwatch_dashboard.json")}"
  vars {
    waf_name = "${replace(var.waf_name, "-", "")}"
    region   = "${data.aws_region.current.name}"
  }
}

resource "aws_cloudwatch_dashboard" "waf" {
  dashboard_name = "WAF_${var.waf_name}"
  dashboard_body = "${data.template_file.dashboard.rendered}"
}
