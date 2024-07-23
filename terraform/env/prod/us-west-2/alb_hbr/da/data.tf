data "aws_acm_certificate" "main" {
  provider    = aws.us-east-1
  domain      = "*.mobilehealthconsumer.com"
  statuses    = ["ISSUED"]
  most_recent = true
}