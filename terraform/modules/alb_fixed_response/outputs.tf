output "lambda_arn" {
  value       = aws_lambda_function.alb_update_FR.arn
  description = "Lambda ARN"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alb_update_FR_lambda.arn
  description = "SNS Topic ARN"
}
