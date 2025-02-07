output "redis_cluster_primary_endpoint" {
  value = aws_elasticache_cluster.redis_cache.primary_endpoint
  description = "Primary endpoint for Redis cluster"
}
