output "vpc_id" {
  value = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
  description = "List of Public Subnet IDs"
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
  description = "List of Private Subnet IDs"
}

output "azs" {
  value = var.azs
  description = "Availability Zones used"
}