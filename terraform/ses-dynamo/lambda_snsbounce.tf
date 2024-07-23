resource "aws_lambda_permission" "allow_sns-SESBounce" {
  statement_id  = "AllowExecutionFromSNS-SESBounce"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sns_notification-sesbounce.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.SESBounce.arn}"
}

data "archive_file" "lambda-sesbounce" {
  type        = "zip"
  source_file = "${path.module}/storeSESBounce_lambda.py"
  output_path = "${path.module}/sesbounce.zip"
}

resource "aws_lambda_function" "sns_notification-sesbounce" {
  filename         = "${path.module}/sesbounce.zip"
  function_name    = "ses_messages_processing-sesbounce"
  role             = "${aws_iam_role.policy.arn}"
  handler          = "storeSESBounce_lambda.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.lambda-sesbounce.output_base64sha256}"
}
