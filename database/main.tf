resource "aws_db_instance" "postgres_db" {
  allocated_storage    = var.db_allocated_storage
  engine               = "postgres"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username # fetched from Secrets Manager in root main.tf
  password             = var.db_password # fetched from Secrets Manager in root main.tf
  vpc_security_group_ids = [var.rds_postgres_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  multi_az             = var.db_multi_az
  availability_zone    = var.db_availability_zone
  skip_final_snapshot  = true # This is just for testing!
  storage_encrypted     = true
  kms_key_id            = var.kms_key_alias_arn

  tags = {
    Name = "postgres-db"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group" # Must be lowercase, hyphen only
  subnet_ids = var.private_subnet_ids # Private subnets for DB
  description = "Subnet group for RDS PostgreSQL"
}
