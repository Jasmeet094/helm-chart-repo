provider "aws" {
  region = "us-west-2"
}

module "redis" {
  source = "../../../../../modules/elasticache"

  common_tags = {
    Application = "Redis"
    Environment = "ofog"
    "Terraform" = "True"
  }
  environment          = "ofog"
  replication_group_id = "ofog-redis-cluster"
  description          = "mhc ofog redis cluster"

  vpc_id           = data.aws_vpc.mhc.id
  redis_subnet_ids = data.aws_subnets.subnets.ids
}
