resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.stage}-main"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stage}-main"
  }
}
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public1_cidr

  tags = {
    Name = "${var.stage}-public_1"
    map_public_ip_on_launch = true
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
    }
  }
resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private1_cidr

  tags = {
    Name = "${var.stage}-private_1"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
    }
  }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.stage}-public"
  }
}
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}