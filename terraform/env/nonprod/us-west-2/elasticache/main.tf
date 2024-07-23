provider "aws" {
  region = "us-west-2"
}

module "redis" {
  source = "../../../../modules/elasticache"

  common_tags = {
    Application = "Redis"
    Environment = "nonprod"
    "Terraform" = "True"
  }
  environment                = "nonprod"
  replication_group_id       = "nonprod-redis-cluster"
  description                = "mhc nonprod redis cluster"
  kms_key_id                 = "arn:aws:kms:us-west-2:913835907225:key/cb2ca0a0-bece-4542-a97f-1b4894f73d65"
  at_rest_encryption_enabled = true

  vpc_id           = data.aws_vpc.mhc.id
  redis_subnet_ids = data.aws_subnets.subnets.ids
}
