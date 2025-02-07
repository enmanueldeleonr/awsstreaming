output "eks_cluster_name" {
  value       = module.eks.count > 0 ? module.eks.0.cluster_name : data.aws_eks_cluster.existing_eks_cluster.0.name
  description = "Name of the EKS cluster"
}

output "rds_postgres_endpoint" {
  value       = module.database.count > 0 ? module.database.0.db_instance_address : "Database not deployed (check modules_to_deploy config)"
  description = "Endpoint of the RDS PostgreSQL instance"
}

output "elasticache_redis_endpoint" {
  value       = module.cache.count > 0 ? module.cache.0.redis_cluster_primary_endpoint : "Cache not deployed (check modules_to_deploy config)"
  description = "Endpoint of the ElastiCache Redis cluster"
}

output "msk_cluster_brokers" {
  value       = module.messaging.count > 0 ? module.messaging.0.msk_cluster_brokers_string : "Messaging not deployed (check modules_to_deploy config)"
  description = "Bootstrap brokers for the MSK cluster"
}

output "vpc_id" {
  value       = module.networking.count > 0 ? module.networking.0.vpc_id : data.aws_vpc.existing_vpc.0.id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value = module.networking.count > 0 ? module.networking.0.private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id
  description = "List of Private Subnet IDs"
}
