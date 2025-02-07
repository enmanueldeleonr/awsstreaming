variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage for the database (GB)"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
}

variable "db_instance_class" {
  type        = string
  description = "Database instance class"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database admin username"
}

variable "db_password" {
  type        = string
  description = "Database admin password (use secrets management in real-world)"
  sensitive   = true
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the database"
}

variable "rds_postgres_sg_id" {
  type        = string
  description = "Security Group ID for RDS PostgreSQL"
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "db_multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment for RDS"
}

variable "db_availability_zone" {
  type        = string
  default     = null
  description = "Availability Zone for single-AZ deployment (or let AWS choose if multi_az = true)"
}

variable "kms_key_alias_arn" {
  type        = string
  description = "ARN of the KMS Key Alias for database encryption"
}