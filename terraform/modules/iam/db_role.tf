resource "aws_iam_role" "db_server" {
  name               = "DBServer-${var.environment}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "db_server_profile" {
  name = "DBServer-${var.environment}"
  role = aws_iam_role.db_server.name
}

resource "aws_iam_role_policy_attachment" "db_cloudwatch_logs_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "db_ec2_snapshot_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = aws_iam_policy.ec2_snapshot_policy.arn
}

resource "aws_iam_role_policy_attachment" "db_kms_encrypt_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = aws_iam_policy.kms_encrypt_policy.arn
}

resource "aws_iam_role_policy_attachment" "db_backup_policy_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

resource "aws_iam_role_policy_attachment" "db_iam_account_alias_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = aws_iam_policy.iam_account_alias.arn
}

resource "aws_iam_role_policy_attachment" "db_s3_put_logs_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = aws_iam_policy.s3_put_logs.arn
}

resource "aws_iam_role_policy_attachment" "db_systems_manager_attach" {
  role       = aws_iam_role.db_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
