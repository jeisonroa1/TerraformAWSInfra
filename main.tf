
### Setup

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
}

## Backend
terraform {
  backend "s3" {
    bucket = "ramp-up-devops-psl"
    key    = "Ivan.RoaM@perficient.com/terraform.tfstate"
    region = "us-west-1"
    # dynamodb_endpoint = ""  
    # dynamodb_table = "terraform-state"
  }
}

## Provider
provider "aws" {
	region     = var.aws_region
}

##Outputs

output "Sql_host" {
  value = aws_db_instance.db_mysql.address
}

output "UI_App" {
  value = aws_lb.web_lb.dns_name
}

output "Bastion_Host_IP" {
  value = aws_instance.bastion-host.public_ip
}


