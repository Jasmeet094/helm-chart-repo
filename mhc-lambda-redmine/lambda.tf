resource "aws_iam_role" "role" {
  name_prefix = "aws2redmine_lambda"

  assume_role_policy = "${data.aws_iam_policy_document.Lambda_Role.json}"
}

data "aws_iam_policy_document" "Lambda_Role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# ToDo: Tighten Scope of these
data "aws_iam_policy_document" "Lambda_Policy" {
  statement {
    sid = "ClouwatchLogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name_prefix = "aws2redmine_lambda_policy_"
  path        = "/"
  description = "lambda premissions"
  policy      = "${data.aws_iam_policy_document.Lambda_Policy.json}"
}

resource "aws_iam_policy_attachment" "attach" {
  name       = "attachment"
  roles      = ["${aws_iam_role.role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "./lambda_code/"
  output_path = "./aws2redmine.zip"
}

resource "random_id" "lambda_random" {
  byte_length = 8
}

resource "aws_lambda_function" "aws2redmine" {
  filename         = "${path.module}/aws2redmine.zip"
  function_name    = "aws2redmine-${random_id.lambda_random.hex}"
  role             = "${aws_iam_role.role.arn}"
  handler          = "redsns.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  memory_size      = "128"
  timeout          = "60"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.aws2redmine.function_name}"
  principal     = "sns.amazonaws.com"
}
