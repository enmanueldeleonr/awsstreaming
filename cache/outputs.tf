output "redis_cluster_primary_endpoint" {
  value = aws_elasticache_cluster.redis_cache.cache_nodes[0].address
  description = "Primary endpoint for Redis cluster"
}
