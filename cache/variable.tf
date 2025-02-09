variable "app_name" {
  type        = string
  description = "Application name - used for resource naming and tagging"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy the cache cluster in"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to deploy the cache cluster in"
}

variable "elasticache_redis_sg_id" {
  type        = string
  description = "Security group ID for the ElastiCache Redis cluster"
}

variable "cache_cluster_id" {
  type        = string
  description = "Unique identifier for the ElastiCache Redis cluster"
}

variable "cache_node_type" {
  type        = string
  description = "Instance type for the ElastiCache Redis cache nodes"
  default     = "cache.t3.medium"
}

variable "engine_version" {
  type        = string
  description = "Redis engine version for the ElastiCache cluster"
  default     = "7.1" # Or specify the desired default Redis version
}

variable "num_cache_nodes" {
  type        = number
  description = "Number of cache nodes in the ElastiCache cluster"
  default     = 1
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones for the cache cluster"
}

variable "kms_key_alias_arn" {
  type        = string
  description = "ARN of the KMS Key Alias to encrypt the cache cluster"
  default     = "" # Optional KMS encryption by default
}