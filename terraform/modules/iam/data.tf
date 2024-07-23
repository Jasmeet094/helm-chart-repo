data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "CloudwatchMetrics"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "ec2_snapshot" {
  statement {
    sid = "EC2Snapshot"
    actions = [
      "ec2:AttachVolume",
      "ec2:CopyImage",
      "ec2:CopySnapshot",
      "ec2:CreateImage",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:Describe*",
      "ec2:DetachVolume",
      "ec2:ModifyVolumeAttribute",
      "ec2:ReportInstanceStatus",

    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "EC2MessagesFullAccess"
    actions = [
      "ec2messages:*"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "kms_encrypt" {
  statement {
    sid = "KMSEncrypt"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:CreateGrant"
    ]
    resources = [
      "arn:aws:kms:*:913835907225:key/*",
      "arn:aws:kms:*:915106308636:key/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_put_logs" {
  statement {
    sid = "S3PutObjectMHCLogs"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::mhc-logs",
      "arn:aws:s3:::mhc-logs/*",
      "arn:aws:s3:::mhc-secure",
      "arn:aws:s3:::mhc-secure/*"
    ]
  }
}

data "aws_iam_policy_document" "backup" {
  statement {
    sid = "InstanceBackupPolicy"
    actions = [
      "backup:Get*",
      "backup:List*",
      "backup:Describe*",
      "backup:StartBackupJob",
      "backup:StartRestoreJob",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "s3_read_only_bucket_policy" {
  statement {
    sid = "ReadOnlyWebBucket"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::www.mobilehealthconsumer.com/*",
      "arn:aws:s3:::www.engagementpoint.com",
      "arn:aws:s3:::qa.engagementpoint.com"
    ]
  }
}

data "aws_iam_policy_document" "iam_account_alias" {
  statement {
    sid = "IAM"
    actions = [
      "iam:ListAccountAliases",
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
  }
}
