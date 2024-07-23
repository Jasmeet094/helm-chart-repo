resource "aws_lambda_permission" "allow_sns-SESDelivery" {
  statement_id  = "AllowExecutionFromSNS-SESDelivery"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sns_notification-sesdelivery.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.SESDelivery.arn}"
}

data "archive_file" "lambda-sesdelivery" {
  type        = "zip"
  source_file = "${path.module}/storeSESDelivery_lambda.py"
  output_path = "${path.module}/sesdelivery.zip"
}

resource "aws_lambda_function" "sns_notification-sesdelivery" {
  filename         = "${path.module}/sesdelivery.zip"
  function_name    = "ses_messages_processing-sesdelivery"
  role             = "${aws_iam_role.policy.arn}"
  handler          = "storeSESDelivery_lambda.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.lambda-sesdelivery.output_base64sha256}"
}
