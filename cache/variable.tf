variable "cache_cluster_id" {
  type        = string
  description = "ID for the ElastiCache Redis cluster"
}

variable "cache_node_type" {
  type        = string
  description = "Node type for ElastiCache Redis"
}

variable "cache_num_nodes" {
  type        = number
  default     = 1
  description = "Number of cache nodes for Redis"
}

variable "cache_engine_version" {
  type        = string
  description = "Redis engine version"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ElastiCache Redis"
}

variable "elasticache_redis_sg_id" {
  type        = string
  description = "Security Group ID for ElastiCache Redis"
}

variable "kms_key_alias_arn" {
  type        = string
  description = "ARN of the KMS Key Alias for cache encryption"
}
