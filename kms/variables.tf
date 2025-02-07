variable "key_prefix" {
  type        = string
  description = "Prefix for KMS key names and aliases"
}

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Number of days before KMS key is deleted (for deletion protection)"
}