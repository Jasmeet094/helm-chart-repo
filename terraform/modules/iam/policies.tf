resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name_prefix = "CloudWatchLogs"
  path        = "/"
  description = "Policy to push logs to CloudWatch"
  policy      = data.aws_iam_policy_document.cloudwatch_logs.json
}

resource "aws_iam_policy" "ec2_snapshot_policy" {
  name_prefix = "EC2Snapshot"
  path        = "/"
  description = "Policy to create EC2 Snapshots"
  policy      = data.aws_iam_policy_document.ec2_snapshot.json
}

resource "aws_iam_policy" "kms_encrypt_policy" {
  name_prefix = "KMSEncrypt"
  path        = "/"
  description = "Policy for managing KMS keys"
  policy      = data.aws_iam_policy_document.kms_encrypt.json
}

resource "aws_iam_policy" "s3_put_logs" {
  name_prefix = "S3PutLogs"
  path        = "/"
  description = "Policy for pushing logs to S3"
  policy      = data.aws_iam_policy_document.s3_put_logs.json
}

resource "aws_iam_policy" "backup_policy" {
  name_prefix = "AWSBackup"
  path        = "/"
  description = "Policy for managing backup"
  policy      = data.aws_iam_policy_document.backup.json
}

resource "aws_iam_policy" "s3_read_only_bucket" {
  name_prefix = "S3ReadBucket"
  path        = "/"
  description = "Policy for reading S3 bucket"
  policy      = data.aws_iam_policy_document.s3_read_only_bucket_policy.json
}

resource "aws_iam_policy" "iam_account_alias" {
  name_prefix = "IAM"
  path        = "/"
  description = "Policy for IAM list account aliases"
  policy      = data.aws_iam_policy_document.iam_account_alias.json
}
