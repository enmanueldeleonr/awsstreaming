locals {
  config = yamldecode(file("config/${var.app_name}.yaml"))
}

module "networking" {
  source = "./networking"
  count = contains(local.config.modules_to_deploy, "networking") && !lookup(local.config.reuse_infrastructure, "networking", false) ? 1 : 0

  vpc_cidr          = local.config.networking.vpc_cidr
  public_subnet_cidrs = local.config.networking.public_subnet_cidrs
  private_subnet_cidrs = local.config.networking.private_subnet_cidrs
  azs               = local.config.networking.azs
}

data "aws_vpc" "existing_vpc" {
  count = lookup(local.config.reuse_infrastructure, "networking", false) ? 1 : 0
  id    = local.config.existing_infrastructure.networking.vpc_id
}

data "aws_subnet" "existing_public_subnets" {
  count = lookup(local.config.reuse_infrastructure, "networking", false) ? length(local.config.existing_infrastructure.networking.public_subnet_ids) : 0
  id    = element(local.config.existing_infrastructure.networking.public_subnet_ids, count.index)
}

data "aws_subnet" "existing_private_subnets" {
  count = lookup(local.config.reuse_infrastructure, "networking", false) ? length(local.config.existing_infrastructure.networking.private_subnet_ids) : 0
  id    = element(local.config.existing_infrastructure.networking.private_subnet_ids, count.index)
}


module "eks" {
  source = "./compute/eks"
  count = contains(local.config.modules_to_deploy, "eks") && !lookup(local.config.reuse_infrastructure, "eks", false) ? 1 : 0

  cluster_name = local.config.eks.cluster_name
  vpc_id       = module.networking.count > 0 ? module.networking.0.vpc_id : data.aws_vpc.existing_vpc.0.id
  subnet_ids   = module.networking.count > 0 ? module.networking.0.private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id

  eks_cluster_sg_id = module.security_groups.eks_cluster_sg_id
  worker_node_sg_id = module.security_groups.eks_worker_node_sg_id

  kms_key_alias_arn = module.kms.kms_key_alias_arn # Pass KMS key ARN for EKS secrets encryption

  depends_on = [module.networking, module.security_groups, module.kms] 
}

data "aws_eks_cluster" "existing_eks_cluster" {
  count = lookup(local.config.reuse_infrastructure, "eks", false) ? 1 : 0
  name  = local.config.existing_infrastructure.eks.cluster_name
}


module "kms" {
  source = "./kms"
  count = contains(local.config.modules_to_deploy, "kms") ? 1 : 0

  key_prefix = local.config.kms.key_prefix
  deletion_window_in_days = lookup(local.config.kms, "deletion_window_in_days", 7)
}

module "database" {
  source = "./database"
  count = contains(local.config.modules_to_deploy, "database") ? 1 : 0

  db_allocated_storage = local.config.database.db_allocated_storage
  db_engine_version    = local.config.database.db_engine_version
  db_instance_class    = local.config.database.db_instance_class
  db_name              = local.config.database.db_name
  db_username          = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).username
  db_password          = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).password
  private_subnet_ids   = lookup(local.config.reuse_infrastructure, "networking", false) ? data.aws_subnet.existing_private_subnets.*.id : module.networking.0.private_subnet_ids
  rds_postgres_sg_id   = module.security_groups.rds_postgres_sg_id
  azs                  = module.networking.count > 0 ? module.networking.0.azs : data.aws_vpc.existing_vpc.0.availability_zones
  db_multi_az          = local.config.database.db_multi_az
  db_availability_zone = local.config.database.db_availability_zone
  kms_key_alias_arn    = module.kms.kms_key_alias_arn

  depends_on = [module.networking, module.kms, module.security_groups, aws_secretsmanager_secret.rds_secret] # Add secret dependency
}

module "cache" {
  source = "./cache"
  count = contains(local.config.modules_to_deploy, "cache") ? 1 : 0

  cache_cluster_id      = local.config.cache.cache_cluster_id
  cache_node_type       = local.config.cache.cache_node_type
  cache_num_nodes       = local.config.cache.cache_num_nodes
  cache_engine_version  = local.config.cache.cache_engine_version
  private_subnet_ids    = lookup(local.config.reuse_infrastructure, "networking", false) ? data.aws_subnet.existing_private_subnets.*.id : module.networking.0.private_subnet_ids
  elasticache_redis_sg_id = module.security_groups.elasticache_redis_sg_id
  kms_key_alias_arn     = module.kms.kms_key_alias_arn

  depends_on = [module.networking, module.security_groups, module.kms]
}

module "messaging" {
  source = "./messaging"
  count = contains(local.config.modules_to_deploy, "messaging") ? 1 : 0

  kafka_cluster_name  = local.config.messaging.kafka_cluster_name
  kafka_version         = local.config.messaging.kafka_version
  kafka_broker_nodes    = local.config.messaging.kafka_broker_nodes
  kafka_instance_type   = local.config.messaging.kafka_instance_type
  private_subnet_ids  = lookup(local.config.reuse_infrastructure, "networking", false) ? data.aws_subnet.existing_private_subnets.*.id : module.networking.0.private_subnet_ids
  msk_cluster_sg_id     = module.security_groups.msk_cluster_sg_id
  kms_key_alias_arn     = module.kms.kms_key_alias_arn

  depends_on = [module.networking, module.security_groups, module.kms]
}


module "security_groups" {
  source = "./security_groups"
  count = contains(local.config.modules_to_deploy, "security_groups") ? 1 : 0
  vpc_id = try(module.networking[0].vpc_id, data.aws_vpc.existing_vpc.0.id)
}


# Data Source and Resource for Secrets Manager

data "aws_secretsmanager_random_password" "rds_password" {
  count = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  password_length              = 16
  exclude_punctuation = true
  exclude_characters  = "\"@/%`'\""
}

resource "aws_secretsmanager_secret" "rds_secret" {
  count = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  name = "${local.config.app_name}/rds-credentials"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  count = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  secret_id     = aws_secretsmanager_secret.rds_secret[0].arn 
  secret_string = jsonencode({ 
    username = "dbadmin",
    password = data.aws_secretsmanager_random_password.rds_password[0].random_password 
  })
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  count       = contains(local.config.modules_to_deploy, "database") ? 1 : 0
  secret_id   = aws_secretsmanager_secret.rds_secret[0].id # Reference the SECRET METADATA RESOURCE
}