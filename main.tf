locals {
  config = yamldecode(file("config/${var.app_name}.yaml"))
  reuse_networking = lookup(local.config.reuse_infrastructure, "networking", false)
  reuse_eks        = lookup(local.config.reuse_infrastructure, "eks", false)
  reuse_database   = lookup(local.config.reuse_infrastructure, "database", false)
  reuse_security_groups = lookup(local.config.reuse_infrastructure, "security_groups", false)
  reuse_kms        = lookup(local.config.reuse_infrastructure, "kms", false)
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "existing_vpc" {
  count = local.reuse_networking ? 1 : 0
  filter {
    name = "tag:Name"
    values = [local.config.networking.vpc_name_tag]
  }
}

data "aws_subnet" "existing_private_subnets" {
  count = local.reuse_networking ? 1 : 0
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.existing_vpc[0].id]
  }
  filter {
    name   = "tag: Tier"
    values = ["Private"]
  }
}

data "aws_subnet" "existing_public_subnets" {
  count = local.reuse_networking ? 1 : 0
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.existing_vpc[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

module "networking" {
  source = "./networking"
  count = contains(local.config.modules_to_deploy, "networking") && !local.reuse_networking ? 1 : 0

  app_name              = var.app_name
  aws_region            = var.aws_region
  vpc_cidr              = local.config.networking.vpc_cidr
  public_subnet_cidrs    = local.config.networking.public_subnet_cidrs
  private_subnet_cidrs   = local.config.networking.private_subnet_cidrs
  azs                   = data.aws_availability_zones.available.names
  vpc_name_tag          = local.config.networking.vpc_name_tag
  create_networking     = !local.reuse_networking
}

module "security_groups" {
  source = "./security_groups"
  count = contains(local.config.modules_to_deploy, "security_groups") && !local.reuse_security_groups ? 1 : 0

  app_name   = var.app_name
  vpc_id     = length(module.networking) > 0 ? module.networking[0].vpc_id : data.aws_vpc.existing_vpc.0.id
}


module "kms" {
  source = "./kms"
  count = contains(local.config.modules_to_deploy, "kms") && !local.reuse_kms ? 1 : 0

  app_name   = var.app_name
  aws_region = var.aws_region
  key_prefix = local.config.kms.key_prefix
}


module "database" {
  source = "./database"
  count = contains(local.config.modules_to_deploy, "database") && !local.reuse_database ? 1 : 0

  app_name              = var.app_name
  aws_region            = var.aws_region
  db_allocated_storage  = local.config.database.db_allocated_storage
  db_instance_class     = local.config.database.db_instance_class
  db_engine_version     = local.config.database.db_engine_version
  db_name               = local.config.database.db_name
  db_multi_az           = local.config.database.db_multi_az
  db_availability_zone  = local.config.database.db_availability_zone
  private_subnet_ids    = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id
  azs                   = length(module.networking) > 0 ? module.networking[0].azs : distinct(data.aws_subnet.existing_private_subnets[*].availability_zone)
  db_username             = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).username
  db_password             = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).password
  kms_key_alias_arn     = length(module.kms) > 0 ? module.kms[0].kms_key_alias_arn : module.kms.kms_key_alias_arn
  rds_postgres_sg_id    = length(module.security_groups) > 0 ? module.security_groups[0].rds_postgres_sg_id : module.security_groups.rds_postgres_sg_id # Get SG from security_groups


  depends_on = [module.networking, module.kms, module.security_groups, aws_secretsmanager_secret.rds_secret]
}

module "cache" {
  source = "./cache"
  count = contains(local.config.modules_to_deploy, "cache") ? 1 : 0

  app_name            = var.app_name
  aws_region          = var.aws_region
  cache_cluster_id        = local.config.cache.cache_cluster_id
  engine_version        = local.config.cache.engine_version
  cache_node_type         = local.config.cache.cache_node_type
  num_cache_nodes         = local.config.cache.num_cache_nodes
  private_subnet_ids      = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id
  azs                     = length(module.networking) > 0 ? module.networking[0].azs : distinct(data.aws_subnet.existing_private_subnets[*].availability_zone)
  elasticache_redis_sg_id = length(module.security_groups) > 0 ? module.security_groups[0].elasticache_redis_sg_id : module.security_groups.elasticache_redis_sg_id
  kms_key_alias_arn       = length(module.kms) > 0 ? module.kms[0].kms_key_alias_arn : module.kms.kms_key_alias_arn

  depends_on = [module.networking, module.security_groups, module.kms]
}

module "messaging" {
  source = "./messaging"
  count = contains(local.config.modules_to_deploy, "messaging") ? 1 : 0

  kafka_version       = local.config.messaging.kafka_version 
  kafka_instance_type = local.config.messaging.kafka_instance_type
  kafka_cluster_name  = local.config.messaging.kafka_cluster_name 
  private_subnet_ids  = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id 
  msk_cluster_sg_id   = length(module.security_groups) > 0 ? module.security_groups[0].msk_cluster_sg_id : module.security_groups.msk_cluster_sg_id 
  kms_key_alias_arn   = length(module.kms) > 0 ? module.kms[0].kms_key_alias_arn : module.kms.kms_key_alias_arn

  depends_on = [module.networking, module.kms]
}


module "eks" {
  source = "./compute/eks"
  count = contains(local.config.modules_to_deploy, "eks") && !local.reuse_eks ? 1 : 0

  cluster_name = local.config.eks.cluster_name
  vpc_id       = length(module.networking) > 0 ? module.networking[0].vpc_id : data.aws_vpc.existing_vpc.0.id
  subnet_ids   = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id

  eks_cluster_sg_id = length(module.security_groups) > 0 ? module.security_groups[0].eks_cluster_sg_id : module.security_groups.eks_cluster_sg_id
  worker_node_sg_id = length(module.security_groups) > 0 ? module.security_groups[0].worker_nodes_sg_id : ""
  kms_key_alias_arn = length(module.kms) > 0 ? module.kms[0].kms_key_alias_arn : module.kms.kms_key_alias_arn

  depends_on = [module.networking, module.security_groups, module.kms]
}

# Data Source and Resource for Secrets Manager

data "aws_secretsmanager_random_password" "rds_password" {
  count               = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  password_length     = 16
  exclude_punctuation = true
  exclude_characters  = "\"@/%`'\""
}

resource "aws_secretsmanager_secret" "rds_secret" {
  count                   = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  name                    = "${local.config.app_name}/rds-credentials"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  count     = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_secret[0].arn
  secret_string = jsonencode({
    username = "dbadmin",
    password = data.aws_secretsmanager_random_password.rds_password[0].random_password
  })
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  count     = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_secret[0].id # Reference the SECRET METADATA RESOURCE
}