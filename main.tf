
### Setup

provider "aws" {
	region     = var.aws_region
}

### VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = var.default_tags
}

### Subnets
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.subnets_cidr,1)
  availability_zone = element(var.azs,1)
  tags = var.default_tags
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.subnets_cidr,2)
  availability_zone = element(var.azs,2)
  tags = var.default_tags
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.subnets_cidr,3)
  availability_zone = element(var.azs,1)
  tags = var.default_tags
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "element(var.subnets_cidr,4"
  availability_zone = element(var.azs,2)
  tags = var.default_tags
}

### Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.default_tags
}

### Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.default_tags
  }

### Route table associatiion with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}