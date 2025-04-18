locals {
  az1 = "${var.region}a"
}

### VPC ###
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  # Enable DNS hostnames 
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.workload}"
  }
}

### Internet Gateway ###
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-${var.workload}"
  }
}

### Private Subnet ###
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rt-${var.workload}-priv1"
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.100.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-priv1"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

### Public Subnet ###
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-${var.workload}-public"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-pub1"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

### Private Subnet ###
resource "aws_route_table" "vpc_endpoints" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rt-${var.workload}-vpce"
  }
}

resource "aws_subnet" "vpc_endpoints" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.188.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-vpce"
  }
}

resource "aws_route_table_association" "vpc_endpoints" {
  subnet_id      = aws_subnet.vpc_endpoints.id
  route_table_id = aws_route_table.vpc_endpoints.id
}
