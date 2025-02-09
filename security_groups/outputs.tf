output "eks_cluster_sg_id" {
  value = aws_security_group.eks_cluster_sg.id
  description = "Security Group ID for EKS cluster control plane"
}

output "eks_worker_node_sg_id" {
  value = aws_security_group.eks_worker_node_sg.id
  description = "Security Group ID for EKS worker nodes"
}

output "rds_postgres_sg_id" {
  value = aws_security_group.rds_postgres.id
  description = "Security Group ID for RDS PostgreSQL"
}

output "elasticache_redis_sg_id" {
  value = aws_security_group.elasticache_redis.id
  description = "Security Group ID for ElastiCache Redis"
}

output "msk_cluster_sg_id" {
  value = aws_security_group.msk_cluster_sg.id
  description = "Security Group ID for MSK cluster"
}

output "worker_nodes_sg_id" {
  description = "Security group ID for worker nodes"
  value       = aws_security_group.eks_worker_node_sg.id
}