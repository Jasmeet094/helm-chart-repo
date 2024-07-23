resource "aws_db_subnet_group" "nonprod" {
  name       = "mhc-nonprod-db-subnet-group"
  subnet_ids = ["subnet-d7ad06b3", "subnet-5ba7d12c", "subnet-977bf3ce"]

  tags = {
    Name = "mhc-nonprod-db-subnet-group"
  }
}

module "rds_parameter_group" {
  source = "../../../../modules/rds-parameter-group"

  name        = "cctests01db"
  description = "cctests01db"
  parameters  = var.cctests01db_parameters
}

module "cctests01db" {
  source = "../../../../modules/rds"

  identifier           = "cctests01db"
  db_subnet_group_name = aws_db_subnet_group.nonprod.name
  parameter_group_name = module.rds_parameter_group.name
  monitoring_role_arn  = "arn:aws:iam::913835907225:role/rds-monitoring-role"
  allocated_storage    = 1500
  instance_class       = "db.m6i.16xlarge"
  availability_zone    = "us-west-2b"
  security_group_ids   = ["sg-f0ea7c94", "sg-12667d75"]
}