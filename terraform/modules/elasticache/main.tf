resource "aws_elasticache_replication_group" "redis_cluster" {
  description                 = var.description
  replication_group_id        = var.replication_group_id
  apply_immediately           = var.apply_immediately
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  at_rest_encryption_enabled  = var.at_rest_encryption_enabled
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs
  kms_key_id                  = var.kms_key_id
  transit_encryption_enabled = true

  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = 6379
  parameter_group_name       = var.parameter_group_name
  automatic_failover_enabled = true
  multi_az_enabled           = true

  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group

  security_group_ids = [aws_security_group.redis_ingress_allow.id]
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = merge({ "Name" = "mhc-${var.environment}-redis-cluster" }, var.common_tags)
}

resource "aws_security_group" "redis_ingress_allow" {
  name        = "mhc-${var.environment}-redis-ingress-allow"
  description = "Redis ingress allow"
  vpc_id      = var.vpc_id
  tags        = merge({ "Name" = "mhc-${var.environment}-redis-ingress-allow" }, var.common_tags)
}

resource "aws_security_group_rule" "redis_ingress_allow_6379" {
  type        = "ingress"
  from_port   = 6379
  to_port     = 6379
  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  description = "Allow TCP (port 6379) traffic inbound to Redis."

  security_group_id = aws_security_group.redis_ingress_allow.id
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "mhc-${var.environment}-redis-subnet-group"
  subnet_ids = var.redis_subnet_ids

  tags = merge({ "Name" = "mhc-${var.environment}-redis-subnet-group" }, var.common_tags)
}

resource "aws_cloudwatch_log_group" "redis" {
  name_prefix = "mhc-${var.environment}-redis-log-group"

  tags = var.common_tags
}
