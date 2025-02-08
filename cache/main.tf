resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = var.cache_cluster_id
  engine               = "redis"
  node_type            = var.cache_node_type
  num_cache_nodes      = var.cache_num_nodes
  subnet_group_name    = aws_elasticache_subnet_group.cache_subnet_group.name
  security_group_ids   = [var.elasticache_redis_sg_id]
  engine_version       = var.cache_engine_version
  transit_encryption_enabled = true

  tags = {
    Name = "redis-cache"
  }
}


resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  name        = "cache-subnet-group"
  subnet_ids = var.private_subnet_ids
  description = "Subnet group for ElastiCache Redis"
}