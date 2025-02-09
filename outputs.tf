output "vpc_id" {
  value = length(module.networking) > 0 ? module.networking[0].vpc_id : data.aws_vpc.existing_vpc[0].id
}

output "private_subnet_ids" {
  value = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnet.existing_private_subnets.*.id
}

output "public_subnet_ids" {
  value = length(module.networking) > 0 ? module.networking[0].private_subnet_ids : data.aws_subnet.existing_public_subnets.*.id
}