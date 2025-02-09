variable "app_name" {
  type        = string
  description = "Application name - used for resource naming and tagging"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy the database in"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to deploy the database in"
}

variable "rds_postgres_sg_id" {
  type        = string
  description = "Security Group ID for the RDS PostgreSQL instance"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB for the database"
  default     = 20
}

variable "db_instance_class" {
  type        = string
  description = "Instance class for the database"
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  type        = string
  description = "Engine version for the PostgreSQL database"
  default     = "15.4"
}

variable "db_name" {
  type        = string
  description = "Name for the PostgreSQL database"
  default     = "mydatabase"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment for the database"
  default     = false
}

variable "db_availability_zone" {
  type        = string
  description = "Availability Zone for the database (required if not Multi-AZ)"
  default     = null
}

variable "db_username" {
  type        = string
  description = "Username for the database administrator"
}

variable "db_password" {
  type        = string
  description = "Password for the database administrator"
  sensitive   = true
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones for the database"
}

variable "kms_key_alias_arn" {
  type        = string
  description = "ARN of the KMS Key Alias to encrypt the database"
  default     = "" # Optional KMS encryption by default
}