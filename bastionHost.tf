# Web - EC2 Instance Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-host-security-group"
  description = "Allowing SSH requests from admins"
  vpc_id = aws_vpc.main.id
  
  ## SSH     
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_instance" "bastion-host" {
  ami                         = var.ami
  availability_zone           = "us-west-1a"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = element(values(aws_subnet.public_subnet).*.id , 0) 
  key_name                    = var.key
 
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.root_device_size
    volume_type           = var.root_device_type
  }
 
  tags = var.default_tags
  depends_on = [aws_security_group.bastion_sg]
}