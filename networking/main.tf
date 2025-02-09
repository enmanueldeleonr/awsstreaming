
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to get the existing VPC when reusing infrastructure
data "aws_vpc" "selected" {
  count = var.create_networking ? 0 : 1
  tags = {
    Name = var.vpc_name_tag
  }
}

# Data source to get private subnets within the selected VPC when reusing
data "aws_subnets" "private" {
  count = var.create_networking ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

# Data source to get public subnets within the selected VPC when reusing
data "aws_subnets" "public" {
  count = var.create_networking ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}


# VPC Resource - Created only when var.create_networking is true
resource "aws_vpc" "main" {
  count = var.create_networking ? 1 : 0
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Internet Gateway - Created only when var.create_networking is true
resource "aws_internet_gateway" "igw" {
  count = var.create_networking ? 1 : 0
  vpc_id = aws_vpc.main[0].id
  tags = {
    Name = "${var.app_name}-igw"
  }
}

# NAT Gateway - Created only when var.create_networking is true
resource "aws_nat_gateway" "nat_gateway" {
  count = var.create_networking ? 1 : 0
  allocation_id = aws_eip.nat_gateway_eip[0].id
  subnet_id = values(aws_subnet.public_subnet)[0].id
  tags = {
    Name = "nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Elastic IP for NAT Gateway - Created only when var.create_networking is true
resource "aws_eip" "nat_gateway_eip" {
  count = var.create_networking ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "nat-gateway-eip"
  }
}


# Public Route Table - Created only when var.create_networking is true
resource "aws_route_table" "public_route_table" {
  for_each = { for az in var.azs : az => az }
  vpc_id = aws_vpc.main[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = {
    Name = "${var.app_name}-public-route-table-${each.key}"
  }
}


# Public Subnets - Created only when var.create_networking is true
resource "aws_subnet" "public_subnet" {
  for_each = { for idx, az in var.azs : az => idx }

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = each.key

  tags = {
    Name = "${var.app_name}-public-subnet-${each.key}"
    Tier = "Public"
  }
}


# Associate Public Subnets with Public Route Table - Created only when var.create_networking is true
resource "aws_route_table_association" "public_subnet_association" {
  for_each = aws_subnet.public_subnet
  subnet_id      = each.value.id  
  route_table_id = aws_route_table.public_route_table[each.key].id
}


# Private Route Table - Created only when var.create_networking is true
resource "aws_route_table" "private_route_table" {
  for_each = aws_subnet.private_subnet
  vpc_id = aws_vpc.main[0].id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
  }
  tags = {
    Name = "${var.app_name}-private-route-table-${each.key}"
  }
}


# Private Subnets - Created only when var.create_networking is true
resource "aws_subnet" "private_subnet" {
  for_each = { for idx, az in var.azs : az => idx }

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + length(var.azs))
  availability_zone = each.key

  tags = {
    Name = "${var.app_name}-private-subnet-${each.key}"
    Tier = "Private"
  }
}


# Associate Private Subnets with Private Route Table - Created only when var.create_networking is true
resource "aws_route_table_association" "private_subnet_association" {
  for_each = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}