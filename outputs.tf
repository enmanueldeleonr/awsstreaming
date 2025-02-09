output "vpc_id" {
  value = length(module.networking) > 0 ? module.networking[0].vpc_id : data.aws_vpc.existing_vpc[0].id
}

output "private_subnet_ids" {
  value = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnets.existing_private_subnets[0].ids
}

output "public_subnet_ids" {
  value = length(module.networking) > 0 ? module.networking[0].public_subnet_ids : data.aws_subnets.existing_public_subnets[0].ids
}