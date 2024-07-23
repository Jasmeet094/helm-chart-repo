/*
This fails with:
> data.aws_cloudformation_stack.fws_sg: data.aws_cloudformation_stack.fws_sg: template body contains an invalid JSON or YAML: invalid character '}' looking for beginning of object key string

data "aws_cloudformation_stack" "fws_sg" {
  name = "MHCVPCv1SG"
}
*/

data "aws_route53_zone" "domain" {
  name         = "${var.domain}."
  private_zone = false
}

data "aws_route53_zone" "internal" {
  name         = "${var.private_domain}."
  private_zone = false
}
