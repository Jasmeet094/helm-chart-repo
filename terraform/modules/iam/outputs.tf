output "web_server_profile" {
  description = "Name of the Web Server instance profile."
  value       = aws_iam_instance_profile.web_server_profile.name
}

output "db_server_profile" {
  description = "Name of the DB Server instance profile."
  value       = aws_iam_instance_profile.db_server_profile.name
}
