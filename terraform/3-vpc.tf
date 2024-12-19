# Internet VPC
resource "aws_vpc" "k8s-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "k8s-vpc"
  }
}

# Subnets
resource "aws_subnet" "k8s-public" {
  vpc_id                  = aws_vpc.k8s-vpc.id
  cidr_block              = var.vpc_public_cidr_block
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "k8s-public"
  }
}


resource "aws_subnet" "k8s-private" {
  vpc_id                  = aws_vpc.k8s-vpc.id
  cidr_block              = var.vpc_private_cidr_block
  map_public_ip_on_launch = "false"
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "k8s-private"
  }
}


# Internet GW
resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

# route tables
resource "aws_route_table" "k8s-vpc-public" {
  vpc_id = aws_vpc.k8s-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }

  tags = {
    Name = "k8s-vpc-public"
  }
}

# route associations public
resource "aws_route_table_association" "k8s-vpc-public-1-a" {
  subnet_id      = aws_subnet.k8s-public.id
  route_table_id = aws_route_table.k8s-vpc-public.id
}



resource "aws_eip" "k8s_eip" {
  domain = "vpc"

  tags = {
    Name = "k8s_eip"
  }
}

resource "aws_nat_gateway" "k8s_natgw" {
  allocation_id = aws_eip.k8s_eip.id
  subnet_id     = aws_subnet.k8s-public.id
  depends_on = [aws_internet_gateway.k8s-igw]  
  tags = {
    Name = "k8s_natgw"
  }
}

resource "aws_route_table" "k8s_routenat" {
  vpc_id = aws_vpc.k8s-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.k8s_natgw.id
  }
tags = {
    Name = "k8s_routenat"
  }
}

resource "aws_route_table_association" "k8s_assonat" {
  subnet_id      = aws_subnet.k8s-private.id
  route_table_id = aws_route_table.k8s_routenat.id
}