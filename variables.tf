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

variable "az_public_subnet" {
	type = map(string)
    default = {
  		"us-west-1a" : "10.0.0.0/24",
  		"us-west-1c" : "10.0.1.0/24"
  	}
}

variable "az_private_subnet" {
	type = map(string) 
    default = {
  		"us-west-1a" : "10.0.101.0/24",
  		"us-west-1c" : "10.0.102.0/24"
  	}
}

variable "az_database_subnet" {
	type = map(string) 
    default = {
  		"us-west-1a" : "10.0.201.0/24",
  		"us-west-1c" : "10.0.202.0/24"
  	}
}

variable "availability_zones" {
	type = list(string)
	default = [
  		"us-west-1a",
  		"us-west-1c"
  	]
}

### Compute
variable "ami" {
	default = "ami-0bdb828fd58c52235"
}

variable "instance_type" {
	default = "t2.micro"
}



