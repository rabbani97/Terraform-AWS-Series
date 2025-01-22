provider "aws" {
  region = var.aws_region
}

# Retrieve the list of AZ in the current region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Define the VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # enable_dns_support = true
  # enable_dns_hostnames = true
  tags = {
    Name       = var.vpc_name
    Enviorment = "Demo_Enviornment"
    Terraform  = true

  }
}

# Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name      = each.key
    Terraform = true
  }
}

# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 100)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name      = each.key
    Terraform = true
  }
}

# Create a route table for the private and public subnets

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "Public Route Table"
    Terraform = true
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "Private Route Table"
    Terraform = true
  }
}

# Create route table association for the private and public subnets
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id

}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id

}

# Create an internet gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name      = "Internet Gateway"
    Terraform = true
  }

}

# Create a EIP for NAT gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name      = "NAT Gateway EIP"
    Terraform = true
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name      = "NAT Gateway"
    Terraform = true
  }
}