output "arn" {
  description = "The ARN of the db instance."
  value       = aws_db_instance.postgres.arn
}

output "address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.postgres.address
}