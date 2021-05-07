
### Networking
## VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = var.default_tags
}

## Subnets
resource "aws_subnet" "public" {
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  tags = var.default_tags
}

## Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.default_tags
}

## Route Table (IG Association) 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.routeTable_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.default_tags
  }

## Route table associatiion with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}

## Load Balancer
resource "aws_lb" "lb_front" {
  name               = "frontend"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
}

## Load balancer attachment
resource "aws_autoscaling_attachment" "asg_front" {
  autoscaling_group_name = aws_autoscaling_group.asg_front.id
  elb                    = aws_lb.lb_front.id
}