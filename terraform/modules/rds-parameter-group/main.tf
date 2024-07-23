resource "aws_db_parameter_group" "group" {
  name        = var.name
  description = var.description
  family      = "postgres14"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }
}