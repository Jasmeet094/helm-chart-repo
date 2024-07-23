resource "aws_db_instance" "postgres" {
  identifier            = var.identifier
  engine                = "postgres"
  engine_version        = "14.8"
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 10000
  storage_type          = var.storage_type
  iops                  = var.iops
  kms_key_id            = var.kms_key_id
  storage_encrypted     = true

  username                            = "postgres"
  password                            = var.password
  manage_master_user_password         = var.password == null ? true : false
  iam_database_authentication_enabled = true

  port                   = 6432
  availability_zone      = var.availability_zone
  multi_az               = var.multi_az
  db_subnet_group_name   = var.db_subnet_group_name
  publicly_accessible    = false
  vpc_security_group_ids = var.security_group_ids

  db_name              = "postgres"
  parameter_group_name = var.parameter_group_name

  allow_major_version_upgrade = false
  #ts:skip=AWS.RDS.DS.High.1041 exclude per client requirements
  auto_minor_version_upgrade = false
  deletion_protection        = true
  backup_window              = "09:00-09:30"
  backup_retention_period    = 7
  copy_tags_to_snapshot      = true
  skip_final_snapshot        = true

  monitoring_role_arn                   = var.monitoring_role_arn
  monitoring_interval                   = 30
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = {
    devops-guru-default = var.identifier
  }
}