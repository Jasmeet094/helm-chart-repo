resource "aws_lambda_permission" "allowcloudwatchevent" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_jumpcloud.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.jumpcloud.arn}"
}

data "archive_file" "lambda-zip" {
  type        = "zip"
  source_dir  = "${path.module}/files/"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda_jumpcloud" {
  filename         = "${path.module}/lambda.zip"
  function_name    = "jumpcloud_to_cloudwatch"
  role             = "${aws_iam_role.policy.arn}"
  handler          = "lambda.lambda_handler"
  runtime          = "python3.6"
  timeout          = 30
  source_code_hash = "${data.archive_file.lambda-zip.output_base64sha256}"
}
