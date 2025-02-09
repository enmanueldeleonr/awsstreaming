output "vpc_id" {
  value = var.create_networking ? aws_vpc.main[0].id : data.aws_vpc.selected[0].id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value = var.create_networking ? aws_subnet.private_subnet.*.id : data.aws_subnets.private[0].ids
  description = "List of Private Subnet IDs"
}

output "public_subnet_ids" {
  value = var.create_networking ? aws_subnet.public_subnet.*.id : data.aws_subnets.public[0].ids
  description = "List of Public Subnet IDs"
}

output "azs" {
  value = var.azs
  description = "List of Availability Zones"
}