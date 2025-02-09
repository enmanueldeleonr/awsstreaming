output "db_instance_address" {
  value       = aws_db_instance.postgres.address
  description = "Database instance address"
}

output "db_instance_port" {
  value       = aws_db_instance.postgres.port
  description = "Database instance port"
}

output "db_instance_username" {
  value       = aws_db_instance.postgres.username
  description = "Database admin username"
}

output "db_instance_password" {
  value       = aws_db_instance.postgres.password # Be cautious with outputting sensitive data in production
  description = "Database admin password"
  sensitive   = true
}

output "db_instance_id" {
  value       = aws_db_instance.postgres.id
  description = "Database instance ID"
}