### General
variable "aws_region" {
	default = "us-west-1"
}

variable "default_tags" { 
    type = map 
    default = { 
    	project: "devops-rampup",
    	responsible: "ivan.roam@perficient.com"
  } 
}

### Networking
variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

variable "routeTable_cidr" {
	default = "0.0.0.0/0"
}

variable "subnets_cidr" {
	type = list
	default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

### Compute
variable "ami" {
	default = "ami-0a245a00f741d6301"
}

variable "azs" {
	type = list
	default = ["us-west-1a", "us-west-1c"]
}

variable "instance_type" {
	default = "t2.micro"
}

