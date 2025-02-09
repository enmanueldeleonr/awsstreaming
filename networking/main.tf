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
  subnet_id     = aws_subnet.public_subnet[0].id
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
  count = var.create_networking ? 1 : 0
  vpc_id = aws_vpc.main[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = {
    Name = "public-route-table"
  }
}


# Public Subnets - Created only when var.create_networking is true
resource "aws_subnet" "public_subnet" {
  count = var.create_networking ? 1 : 0
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}


# Associate Public Subnets with Public Route Table - Created only when var.create_networking is true
resource "aws_route_table_association" "public_subnet_association" {
  count = var.create_networking ? 1 : 0
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[0].id
}


# Private Route Table - Created only when var.create_networking is true
resource "aws_route_table" "private_route_table" {
  count = var.create_networking ? 1 : 0
  vpc_id = aws_vpc.main[0].id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
  }
  tags = {
    Name = "private-route-table"
  }
}


# Private Subnets - Created only when var.create_networking is true
resource "aws_subnet" "private_subnet" {
  count = var.create_networking ? 1 : 0
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}


# Associate Private Subnets with Private Route Table - Created only when var.create_networking is true
resource "aws_route_table_association" "private_subnet_association" {
  count = var.create_networking ? 1 : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[0].id
}