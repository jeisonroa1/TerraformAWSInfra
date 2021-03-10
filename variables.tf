variable "aws_region" {
	default = "us-west-1"
}

variable "vpc_cidr" {
	default = "10.0.0.0/24"
}

variable "subnets_cidr" {
	type = list
	default = ["10.0.1.0/16", "10.0.2.0/16", "10.0.3.0/16", "10.20.3.0/16"]
}

variable "azs" {
	type = list
	default = ["us-west-1a", "us-west-1b"]
}

variable "default_tags" { 
    type = map 
    default = { 
    	project: "devops-rampup",
    	responsible: "ivan.roam@perficient.com"
  } 
}