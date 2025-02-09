output "vpc_id" {
  value = var.create_networking ? aws_vpc.main[0].id : data.aws_vpc.selected[0].id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value = var.create_networking ? values(aws_subnet.private_subnet)[*].id : flatten([for i in range(length(data.aws_subnets.private)) : data.aws_subnets.private[i].ids])
}
output "public_subnet_ids" {
  value = var.create_networking ? values(aws_subnet.public_subnet)[*].id : flatten([for i in range(length(data.aws_subnets.public)) : data.aws_subnets.public[i].ids])
}

output "azs" {
  value = var.azs
  description = "List of Availability Zones"
}