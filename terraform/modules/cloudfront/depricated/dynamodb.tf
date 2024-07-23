# locals {
#   key        = "siteUrl"
#   count      = "count"
#   table_name = local.name
# }

# resource "aws_dynamodb_table" "table" {
#   provider = aws.us-east-1
#   attribute {
#     name = local.key
#     type = "S"
#   }

#   hash_key       = local.key
#   name           = local.table_name
#   read_capacity  = var.read_capacity
#   write_capacity = var.write_capacity
#   tags = {
#     Environment = lower(var.environment) == "production" ? "p" : lower(var.environment)
#   }
# }

# module "table_autoscaling" {
#   providers = {
#     "aws" = aws.us-east-1
#   }
#   source              = "./m-autoscaling"
#   resource_id         = aws_dynamodb_table.table.id
#   type                = "table"
#   capacity            = var.capacity
#   target_value        = var.target_value
#   autoscaling_enabled = var.autoscaling_enabled
# }
