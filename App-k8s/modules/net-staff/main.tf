#### VPC Creation ####
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}
#### IGateway Creation #####
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-main"
  }
}
### Subnets Creation #########
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "sub-public1"
    map_public_ip_on_launch = true
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
    }
  }
  resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "sub-public-2"
    map_public_ip_on_launch = true
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
    }
  }
resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "sub-private1"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
    }
  }
resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "sub-private2"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
    }
  }

  ### Elastic Ips Creation  #####
  resource "aws_eip" "nat1" {
    depends_on = [aws_internet_gateway.gw]  
  }
  resource "aws_eip" "nat2" {
    depends_on = [aws_internet_gateway.gw] 
  }
  resource "aws_nat_gateway" "nat1" {
    allocation_id = aws_eip.nat1.id
    subnet_id = aws_subnet.public_1.id
    tags = {
      "Name" = "gw-nat1"
    }  
  }
  resource "aws_nat_gateway" "nat2" {
    allocation_id = aws_eip.nat2.id
    subnet_id = aws_subnet.public_2.id
    tags = {
      "Name" = "gw-nat2"
    }  
  }
#### Route Tables Creation #####
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "rtable-public"
  }
}
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "rtable-private1"
  }
}
resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat2.id
  }
  tags = {
    Name = "rtable-private2"
  }
}

### Route Table Associations ######
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private1.id
}
resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private2.id
}