output "jumpcloud_api_key_arn" {
  value = aws_secretsmanager_secret.jumpcloud_api_key.arn
}

output "ses_user_secret_arn" {
  value = aws_secretsmanager_secret.ses_smtp_user.arn
}