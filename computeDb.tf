## DB
# DB - Security Group
resource "aws_security_group" "db_security_group" {
  name = "mydb1"

  description = "RDS mySQL server" 
  vpc_id = aws_vpc.main.id

  # Only Mysql in
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app_instance_sg.id, aws_security_group.bastion_sg.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB - Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids = [for value in aws_subnet.database_subnet: value.id]
  tags = var.default_tags
}

# DB - RDS Instance
resource "aws_db_instance" "db_mysql" {
  allocated_storage        = 10 # gigabytes
  backup_retention_period  = 7   # in days
  db_subnet_group_name     = aws_db_subnet_group.db_subnet.name
  engine                   = "mysql"
  engine_version           = "5.7"
  identifier               = "dbmysql"
  instance_class           = "db.t3.micro"
  multi_az                 = false
  name                     = var.db_name
  username                 = var.db_user
  password                 = var.db_pass
  port                     = 3306
  publicly_accessible      = true #
  storage_encrypted        = true
  storage_type             = "gp2"
  vpc_security_group_ids   = [aws_security_group.db_security_group.id]
  skip_final_snapshot      = true
  tags = var.default_tags
}
