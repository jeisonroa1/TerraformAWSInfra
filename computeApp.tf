## APP

# App - ALB Security Group
resource "aws_security_group" "alb_app_http" {
  name        = "alb-app-security-group"
  description = "Allowing HTTP requests to the app tier application load balancer"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.web_instance_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = var.default_tags
  depends_on = [aws_route_table_association.private_subnet_route_table_association, aws_security_group.web_instance_sg]
}


# App - EC2 Instance Security Group
resource "aws_security_group" "app_instance_sg" {
  name        = "app-server-security-group"
  description = "Allowing requests to the app servers"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_app_http.id] 
  }

  ## SSH
  ingress {   
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = var.default_tags
  depends_on = [aws_security_group.alb_app_http]
}

# App - Application Load Balancer
resource "aws_lb" "app_lb" {
  name = "app-lb"
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_app_http.id]
  subnets = [for value in aws_subnet.private_subnet: value.id]
  tags = var.default_tags
  depends_on = [aws_security_group.alb_app_http]
}

locals {
  backend_dns = aws_lb.app_lb.dns_name
}

# App - Target Group
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 3000
    protocol = "HTTP"
  }
  tags = var.default_tags
  depends_on = [aws_lb.app_lb]
}

# App - Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
  depends_on = [aws_lb_target_group.app_target_group]
}

# App - Launch Template
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_instance_sg.id]
  user_data = base64encode("${file("init-app-instance.sh")}\nDB_HOST=${aws_db_instance.db_mysql.address} DB_USER=${var.db_user} DB_PASS=${var.db_pass} DB_NAME=${var.db_name} node /home/ubuntu/movie-analyst-api/server.js &")
  tags = var.default_tags
  key_name = var.key
  depends_on = [aws_security_group.app_instance_sg]  
}

# App - Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity   = 1
  max_size           = 2
  min_size           = 0
  target_group_arns = [aws_lb_target_group.app_target_group.arn]
  vpc_zone_identifier = [for value in aws_subnet.private_subnet: value.id]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.app_launch_template]
}
