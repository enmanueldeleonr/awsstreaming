output "cache_cluster_id" {
  value       = aws_elasticache_cluster.redis.cluster_id
  description = "The ID of the ElastiCache Redis cluster"
}

output "cache_cluster_endpoint" {
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
  description = "The endpoint to connect to the ElastiCache Redis cluster"
}

output "cache_cluster_port" {
  value       = aws_elasticache_cluster.redis.port
  description = "The port of the ElastiCache Redis cluster"
}