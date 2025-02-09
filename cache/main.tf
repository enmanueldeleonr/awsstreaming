resource "aws_elasticache_cluster" "redis" {
  cluster_id         = var.cache_cluster_id
  engine             = "redis"
  node_type          = var.cache_node_type
  num_cache_nodes    = var.num_cache_nodes
  engine_version     = var.engine_version
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [var.elasticache_redis_sg_id]

  tags = {
    Name        = "${var.app_name}-${var.cache_cluster_id}-cache-cluster" # Use app_name in naming
    Application = var.app_name # Use app_name for tagging
  }
  depends_on = [ aws_elasticache_subnet_group.redis ]
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.app_name}-cache-subnet-group" # Use app_name in naming
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for redis cache cluster"
}