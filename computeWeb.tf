## WEB

# Web - ALB Security Group
resource "aws_security_group" "alb_http" {
  name        = "alb-web-security-group"
  description = "Allowing HTTP requests to the application load balancer"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = var.default_tags
}

# Web - EC2 Instance Security Group
resource "aws_security_group" "web_instance_sg" {
  name        = "web-server-security-group"
  description = "Allowing requests to the web servers"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_http.id]
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
  depends_on = [aws_security_group.alb_http]
}

# Web - Application Load Balancer
resource "aws_lb" "web_lb" {
  name = "web-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_http.id]
  subnets = [for value in aws_subnet.public_subnet: value.id]
  tags = var.default_tags
  depends_on = [aws_security_group.alb_http]
}

# Web - Target Group
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 3030
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 3030
    protocol = "HTTP"
  }
  tags = var.default_tags
  depends_on = [aws_lb.web_lb]
}

# Web - Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "3030"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
  depends_on = [aws_lb_target_group.web_target_group]
}

# Web - Launch Template
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "web-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_instance_sg.id]
  user_data = base64encode("${file("init-web-instance.sh")}\nBACK_HOST=${local.backend_dns} node /home/ubuntu/movie-analyst-ui/server.js &")
  tags = var.default_tags
  key_name = var.key    
  depends_on = [aws_lb_listener.web_listener, aws_lb.app_lb] 
}

# Web - Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity   = 1
  max_size           = 2
  min_size           = 0
  target_group_arns = [aws_lb_target_group.web_target_group.arn]
  vpc_zone_identifier = [for value in aws_subnet.public_subnet: value.id]

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.web_launch_template] 
}

