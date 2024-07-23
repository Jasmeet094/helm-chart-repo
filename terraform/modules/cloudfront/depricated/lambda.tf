# data "aws_iam_policy_document" "assume-role" {
#   statement {
#     sid     = ""
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type = "Service"
#       identifiers = [
#         "lambda.amazonaws.com",
#         "edgelambda.amazonaws.com"
#       ]
#     }
#   }
# }

# data "aws_iam_policy_document" "default" {
#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#     actions   = ["logs:CreateLogGroup"]
#   }

#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}:*"]

#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]
#   }
#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["*"]

#     actions = [
#       "dynamodb:*"
#     ]
#   }
# }

# resource "aws_iam_role" "default" {
#   provider           = aws.us-east-1
#   name_prefix        = local.name
#   assume_role_policy = data.aws_iam_policy_document.assume-role.json
# }

# resource "aws_iam_role_policy" "cloudwatch" {
#   provider = aws.us-east-1
#   role     = aws_iam_role.default.name
#   policy   = data.aws_iam_policy_document.default.json
# }


# resource "local_file" "config" {
#   content = templatefile(("${path.module}/template/lambda_edge_url.tpl"), {
#     tablename = local.table_name
#   })
#   filename = "${path.module}/lambda_edge_url.py"
# }

# data "archive_file" "init" {
#   depends_on  = [local_file.config]
#   type        = "zip"
#   source_file = local_file.config.filename
#   output_path = "${path.module}/lambda_edge_url/init.zip"
# }

# resource "aws_lambda_permission" "cloudfront" {
#   provider      = aws.us-east-1
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda_edge.function_name
#   principal     = "cloudfront.amazonaws.com"
# }


# resource "aws_lambda_function" "lambda_edge" {
#   provider         = aws.us-east-1
#   function_name    = local.name
#   filename         = data.archive_file.init.output_path
#   role             = aws_iam_role.default.arn
#   handler          = "lambda_edge_url.handler"
#   runtime          = "python3.8"
#   memory_size      = 128
#   timeout          = 3
#   source_code_hash = data.archive_file.init.output_base64sha256
#   publish          = true
#   tags = {
#     Environment = lower(var.environment) == "production" ? "p" : lower(var.environment)
#   }
# }

locals {
  name = "${lower(var.environment)}-default-route"
}