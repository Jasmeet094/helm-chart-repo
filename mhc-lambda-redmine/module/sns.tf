resource "aws_sns_topic_subscription" "attach_to_lambda" {
  topic_arn = "${data.aws_sns_topic.sns_topic.arn}"
  protocol  = "lambda"
  endpoint  = "${var.lambda_aws2redmine_arn}"
}
