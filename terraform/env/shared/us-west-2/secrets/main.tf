resource "aws_secretsmanager_secret" "jumpcloud_api_key" {
  name        = "jumpcloud-api-key"
  description = "JumpCloud API key"
  kms_key_id  = "arn:aws:kms:us-west-2:913835907225:key/8fbc4b10-316e-4cb2-8c72-19957c93dc44"
}

resource "aws_secretsmanager_secret" "ses_smtp_user" {
  name        = "ses-smtp-user"
  description = "SES SMTP user creds"
  kms_key_id  = "arn:aws:kms:us-west-2:913835907225:key/8fbc4b10-316e-4cb2-8c72-19957c93dc44"
}