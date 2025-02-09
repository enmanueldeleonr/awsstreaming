variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Number of days before KMS key is deleted (for deletion protection)"
}

variable "app_name" { # Likely still uses app_name for resource naming
  type        = string
  description = "Application name"
}

variable "aws_region" { # Likely still uses aws_region for region context
  type        = string
  description = "AWS region"
}

variable "key_prefix" { # <---- REQUIRED variable, as per the error
  type        = string
  description = "Prefix for KMS key alias"
  validation { # Example validation - adjust as needed
    condition     = length(var.key_prefix) > 0
    error_message = "Key prefix must be at least 1 character long."
  }
}