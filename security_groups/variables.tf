variable "vpc_id" {
  type        = string
  description = "VPC ID to create Security Groups in"
}

variable "app_name" { 
  type        = string
  description = "Application name - used for naming security groups"
}