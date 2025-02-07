output "db_instance_address" {
  value = aws_db_instance.postgres_db.address
  description = "RDS instance address"
}

output "db_instance_port" {
  value = aws_db_instance.postgres_db.port
  description = "RDS instance port"
}