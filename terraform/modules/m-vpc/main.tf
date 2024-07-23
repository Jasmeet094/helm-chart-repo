terraform {
  required_version = ">= v0.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_availability_zones" "main" {
  state = "available"
}

data "aws_s3_bucket" "flow_logs" {
  count = var.enable_flow_logs && var.flow_log_bucket != "" ? 1 : 0

  bucket = var.flow_log_bucket
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tag_map
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = var.instance_tenancy

  tags = var.tag_map
}

resource "aws_s3_bucket" "flow_logs" {
  count = var.flow_log_bucket == "" && var.enable_flow_logs ? 1 : 0

  force_destroy = true

  tags = var.tag_map
}

resource "aws_s3_bucket_acl" "flow_logs" {
  count = var.flow_log_bucket == "" && var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id
  acl    = "private"
}

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination      = var.flow_log_bucket != "" ? data.aws_s3_bucket.flow_logs[0].arn : aws_s3_bucket.flow_logs[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

# Remove all rules in default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}
