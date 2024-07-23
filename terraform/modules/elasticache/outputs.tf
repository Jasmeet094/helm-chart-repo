output "redis_cluster_arn" {
  description = "ARN of the redis elasticache cluster."
  value       = aws_elasticache_replication_group.redis_cluster.arn
}

output "endpoint_address" {
  description = "Endpoint address of the redis elasticache cluster."
  value       = aws_elasticache_replication_group.redis_cluster.configuration_endpoint_address
}
