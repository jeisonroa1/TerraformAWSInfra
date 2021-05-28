### General
variable "aws_region" {
	default = "us-west-1"
}

variable "default_tags" { 
    type = map 
    default = { 
    	project: "devops-rampup",
    	responsible: "Ivan.RoaM@perficient.com"
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
	default = "ami-0d382e80be7ffdae5"  #Ubuntu: ami-0d382e80be7ffdae5 , Amazon Linux 2 ami-04468e03c37242e1e, Redhat ami-09d9c5cdcfb8fc655
}

variable "instance_type" {
	default = "t2.micro"
}

variable "key" {
  default = "Roam"
}

### Db
variable "db_user" {
  default = "dbadmin"
}

variable "db_pass" {
  default = "dbpass1234567!"
}

variable "db_name" {
  default = "movie_db"
}

### Bastion Host
variable "root_device_type" {
  description = "Type of the root block device"
  type        = string
  default     = "gp2"
}
 
variable "root_device_size" {
  description = "Size of the root block device"
  type        = string
  default     = "20"
}



