output "name" {
  description = "The name of the DB parameter group."
  value       = aws_db_parameter_group.group.name
}

output "arn" {
  description = "The arn of the DB parameter group."
  value       = aws_db_parameter_group.group.arn
}