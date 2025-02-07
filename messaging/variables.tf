variable "kafka_cluster_name" {
  type        = string
  description = "Name for the MSK Kafka cluster"
}

variable "kafka_version" {
  type        = string
  description = "Kafka version for MSK"
}

variable "kafka_broker_nodes" {
  type        = number
  default     = 3
  description = "Number of broker nodes for MSK"
}

variable "kafka_instance_type" {
  type        = string
  description = "Instance type for MSK brokers"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for MSK"
}

variable "msk_cluster_sg_id" {
  type        = string
  description = "Security Group ID for MSK cluster"
}

variable "kms_key_alias_arn" {
  type        = string
  description = "ARN of the KMS Key Alias for Kafka encryption"
}