
output "db" {
  value = aws_security_group.db
}


output "web" {
  value = aws_security_group.web
}


output "lb" {
  value = aws_security_group.lb
}