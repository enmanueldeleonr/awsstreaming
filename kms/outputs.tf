output "kms_key_arn" {
  value       = aws_kms_key.data_encryption_key.arn
  description = "ARN of the KMS Data Encryption Key"
}

output "kms_key_alias_arn" {
  value       = aws_kms_alias.data_encryption_key_alias.arn
  description = "ARN of the KMS Data Encryption Key Alias"
}