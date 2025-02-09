variable "app_name" {
  type        = string
  description = "Name of the application (used to select YAML config file)"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1" # Default AWS Region
  description = "AWS Region to deploy to"
}
