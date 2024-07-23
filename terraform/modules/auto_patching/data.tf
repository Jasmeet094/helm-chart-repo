data "terraform_remote_state" "s3_patching_logs" {
  backend = "s3"
  config = {
    bucket         = "mhc-terraformstate-us-west-2-prod"
    key            = "terraform/env/shared/us-west-2/s3/patching-logs-bucket"
    dynamodb_table = "tf-state-locking"
    region         = "us-west-2"
  }
}

data "aws_iam_policy_document" "sts_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_publish" {
  statement {
    sid = "SnsPublish"

    actions = [
      "sns:Publish*"
    ]

    resources = [
      "arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c"
    ]
  }
}