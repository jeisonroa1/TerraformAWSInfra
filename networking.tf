
### Networking
# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = var.default_tags
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.default_tags
  depends_on = [aws_vpc.main]
}

resource "aws_default_route_table" "main_table" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.default_tags
  depends_on = [aws_internet_gateway.igw]
}

#  Public Subnet
resource "aws_subnet" "public_subnet" {
  for_each = var.az_public_subnet
  vpc_id = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value 
  map_public_ip_on_launch = true 
  tags = var.default_tags
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  for_each = var.az_private_subnet
  vpc_id = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = var.default_tags
}

# Database Subnet
resource "aws_subnet" "database_subnet" {
  for_each = var.az_database_subnet
  vpc_id = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = var.default_tags
}

# Public Subnet Route Table 
#resource "aws_route_table" "public_subnet_route_table" {
#  vpc_id = aws_vpc.main.id
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.igw.id
#  }
#  tags = var.default_tags
#}

# Public subnet route table association
#resource "aws_route_table_association" "public_subnet_route_table_association" {
#  for_each = var.az_public_subnet
#  subnet_id      = aws_subnet.public_subnet[each.key].id
#  route_table_id = aws_route_table.public_subnet_route_table.id
#}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = var.default_tags
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(values(aws_subnet.public_subnet).*.id , 1 )
  tags = var.default_tags
  depends_on = [aws_eip.nat_eip , aws_subnet.public_subnet]
}

# Private Subnet Route Table 
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = var.default_tags
  depends_on = [aws_nat_gateway.nat_gw , aws_subnet.private_subnet , aws_subnet.database_subnet]
}

# Private subnet Route Table association
resource "aws_route_table_association" "private_subnet_route_table_association" {
  count = length(values(aws_subnet.private_subnet).*.id)
  route_table_id = aws_route_table.private_subnet_route_table.id
  subnet_id      = element(values(aws_subnet.private_subnet).*.id, count.index)
  depends_on = [aws_route_table.private_subnet_route_table]
}
