provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "mhc_prod" {}

resource "aws_lambda_permission" "sns_trigger" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alb_update_FR.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alb_update_FR_lambda.arn
}

resource "aws_sns_topic" "alb_update_FR_lambda" {
  name = "ALB-health-status"
}

resource "aws_sns_topic_subscription" "alb_update_FR_lambda" {
  topic_arn = aws_sns_topic.alb_update_FR_lambda.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alb_update_FR.arn
}

resource "aws_iam_role" "alb_update_FR_lambda_role" {
  name = "alb_update_FR_lambda_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

data "aws_iam_policy_document" "alb_update_FR_policy" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.mhc_prod.account_id}:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.mhc_prod.account_id}:log-group:/aws/lambda/alb_update_FR:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_update_FR_policy" {
  name   = "alb_update_FR"
  path   = "/"
  policy = data.aws_iam_policy_document.alb_update_FR_policy.json
}

resource "aws_iam_role_policy_attachment" "alb_update_FR_lambda" {
  role       = aws_iam_role.alb_update_FR_lambda_role.name
  policy_arn = aws_iam_policy.alb_update_FR_policy.arn
}

data "archive_file" "alb_update_FR_zip" {
  type        = "zip"
  source_file = "${path.module}/files/alb_update_FR.py"
  output_path = "${path.module}/files/alb_update_FR.zip"
}


resource "aws_lambda_function" "alb_update_FR" {
  filename         = data.archive_file.alb_update_FR_zip.output_path
  source_code_hash = data.archive_file.alb_update_FR_zip.output_base64sha256
  function_name    = "alb_update_FR"
  role             = aws_iam_role.alb_update_FR_lambda_role.arn
  handler          = "alb_update_FR.lambda_handler"
  runtime          = "python3.7"
  timeout          = "30"

  environment {
    variables = {
      elb_arn_pre = "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.mhc_prod.account_id}:loadbalancer/"
    }
  }
}
