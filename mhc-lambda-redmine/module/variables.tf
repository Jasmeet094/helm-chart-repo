# data "aws_region" "current" {}
#
# data "aws_caller_identity" "current" {}
#
# locals {
#   fogops_lambda_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_name}"
# }

variable "lambda_name" {}

variable "lambda_aws2redmine_arn" {}

data "aws_sns_topic" "sns_topic" {
  name = "${var.lambda_name}"
}
