resource "aws_mq_broker" "rabbit_mq_broker" {
  broker_name = "mhc-${var.environment}-rabbit-mq-broker"

  engine_type                = "RabbitMQ"
  engine_version             = var.engine_version
  host_instance_type         = var.instance_type
  storage_type               = "ebs"
  deployment_mode            = var.deployment_mode
  security_groups            = [aws_security_group.broker_ingress_allow.id]
  publicly_accessible        = var.publicly_accessible
  subnet_ids                 = var.broker_subnet_ids
  authentication_strategy    = "simple"
  auto_minor_version_upgrade = true

  user {
    username = var.console_username
    password = var.console_password
  }

  logs {
    general = true
  }

  tags = merge({ "Name" = "mhc-${var.environment}-rabbit-mq-broker" }, var.common_tags)

  encryption_options {
    kms_key_id        = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
    use_aws_owned_key = false
  }
}

resource "aws_security_group" "broker_ingress_allow" {
  name        = "mhc-${var.environment}-rabbit-mq-broker-ingress-allow"
  description = "RabbitMQ broker instance ingress allow"
  vpc_id      = var.vpc_id
  tags        = merge({ "Name" = "mhc-${var.environment}-rabbit-mq-broker-sg" }, var.common_tags)
}

resource "aws_security_group_rule" "broker_ingress_https_allow" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  description = "Allow HTTPS (port 443) traffic inbound to RabbitMQ broker instance."

  security_group_id = aws_security_group.broker_ingress_allow.id
}

resource "aws_security_group_rule" "broker_ingress_ampqp_allow" {
  type        = "ingress"
  from_port   = 5671
  to_port     = 5671
  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  description = "Allow TCP (port 5671) traffic inbound to RabbitMQ listener for AMQP."

  security_group_id = aws_security_group.broker_ingress_allow.id
}
