resource "aws_db_instance" "postgres" {
  allocated_storage    = var.db_allocated_storage
  instance_class       = var.db_instance_class
  engine               = "postgres"
  engine_version       = var.db_engine_version
  db_name              = var.db_name
  multi_az             = var.db_multi_az
  availability_zone    = var.db_availability_zone # will be null if multi_az = true, and AZ is chosen by AWS
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [var.rds_postgres_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.private.name
  kms_key_id             = var.kms_key_alias_arn != "" ? var.kms_key_alias_arn : null # Conditional KMS encryption
  storage_encrypted      = var.kms_key_alias_arn != "" ? true : false # Enable encryption if KMS key provided


  identifier           = "${var.app_name}-postgres-db" # Include app_name in identifier
  skip_final_snapshot  = true

  tags = {
    Name        = "${var.app_name}-postgres-db" # Include app_name in Name tag
    Application = var.app_name                  # Application tag
  }
}


resource "aws_db_subnet_group" "private" {
  name       = "${var.app_name}-db-subnet-group" # Include app_name in name
  subnet_ids = var.private_subnet_ids
  description = "Private subnet group for postgres db"

  tags = {
    Name        = "${var.app_name}-db-subnet-group" # Include app_name in Name tag
    Application = var.app_name                      # Application tag
  }
}