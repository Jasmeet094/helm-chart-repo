locals {
  parameter_groups = {
    base = {
      name       = "mhc-base"
      parameters = var.base_parameters
    }
    enhanced_logging = {
      name       = "mhc-enhanced-logging"
      parameters = concat(var.base_parameters, var.enhanced_logging_parameters)
    }
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name               = "rds-monitoring-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_assume_role.json
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_subnet_group" "prod" {
  name       = "mhc-prod-db-subnet-group"
  subnet_ids = ["subnet-c58e20a1", "subnet-19bd7e6f", "subnet-33ddcf6a"]

  tags = {
    Name = "mhc-prod-db-subnet-group"
  }
}

module "rds_parameter_group" {
  source = "../../../../modules/rds-parameter-group"

  for_each = local.parameter_groups

  name       = each.value["name"]
  parameters = each.value["parameters"]
}
