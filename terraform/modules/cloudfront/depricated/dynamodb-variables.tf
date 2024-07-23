
data "aws_region" "current" {
  provider = aws.us-east-1
}

# variable "type" {
#   default = "table"
# }

# variable "capacity" {
#   type = map

#   default = {
#     min_read  = 5
#     max_read  = 20
#     min_write = 5
#     max_write = 20
#   }
# }

# # variable "key" {}
# # variable "table_name" {}

# variable "read_capacity" {
#   default = 5
# }

# variable "write_capacity" {
#   default = 5
# }

# variable "autoscaling_enabled" {
#   default = true
# }

# variable "target_value" {
#   default = 70
# }
