## Bastion bastion

# S3 Artifact Repo Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "rampupartifactrepo"
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 7
    }   
  }
  tags = var.default_tags
}

# IAM Role
resource "aws_iam_role" "bastion_role" {
  name                = "bastion_role"
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
      },
      {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
      },
      {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
  })
  tags = var.default_tags  
}

# IAM Role Policy
resource "aws_iam_role_policy" "bastion_policy" {
  name = "bastion_policy"
  role = aws_iam_role.bastion_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Describe*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]  
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["rds:Describe*"] 
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_profile"
  role = aws_iam_role.bastion_role.name
  depends_on = [aws_iam_role.bastion_role]
}

# Bastion Host Security Group
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

  ## Jenkins     
  ingress {
    from_port = 8080
    to_port = 8080
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
  depends_on = [aws_vpc.main]
}

# Bastion Host Instance
resource "aws_instance" "bastion-host" {
  ami                         = var.ami
  availability_zone           = "us-west-1a"
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
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
  depends_on = [aws_security_group.bastion_sg , aws_subnet.public_subnet, aws_iam_instance_profile.bastion_profile]
}