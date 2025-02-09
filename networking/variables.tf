variable "create_networking" {
  type        = bool
  description = "Flag to control whether to create new networking resources or reuse existing ones"
  default     = true
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "vpc_name_tag" {
  type        = string
  description = "Value of the Name tag for the existing VPC to use when reusing infrastructure"
  default     = "main-vpc"
}