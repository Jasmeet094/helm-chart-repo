resource "aws_cloudwatch_event_rule" "jumpcloud" {
  name                = "JumpcloudReport"
  description         = "Run a job at the top of the day"
  schedule_expression = "cron(30 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "jumpcloud" {
  rule = "${aws_cloudwatch_event_rule.jumpcloud.name}"
  arn  = "${aws_lambda_function.lambda_jumpcloud.arn}"
}
