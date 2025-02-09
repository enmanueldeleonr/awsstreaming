variable "config_file" {
  type        = string
  description = "Path to the configuration YAML file"
  default     = "config.yaml"
}

variable "app_name" {
  type        = string
  description = "Application name (passed to modules)"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region (passed to modules)"
}