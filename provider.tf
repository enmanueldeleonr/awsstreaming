terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# variables.tf
variable "app_name" {
  type        = string
  description = "Name of the application (used to select YAML config file)"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1" # Default AWS Region
  description = "AWS Region to deploy to"
}
