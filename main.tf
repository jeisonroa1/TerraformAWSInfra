
provider "aws" {
	region = "eu-west-1"
}

provider "aws" {
	region     = "eu-west-1"
	access_key = "XXXXXXXXXXXXXXXXX"
	secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}


//VPC
"ramp_up_training" : "vpc-0d2831659ef89870c"

//Se dispone de 2 subnets privadas y 2 publicas
"ramp_up_training-public-0" : "subnet-0088df5de3a4fe490"
"ramp_up_training-public-1" : "subnet-055c41fce697f9cca"
"ramp_up_training-private-0" : "subnet-0088df5de3a4fe490"
"ramp_up_training-private-1" : "subnet-038fa9d9a69d6561e"


//Por cuestiones de costos, se crea una sola NAT.
//En un ambiente de produccion, se deberian crear mas de una en diferentes zonas de disponibilidad
"ramp_up_training-nat-gateway" : "nat-024aa998183a9db83"

"ramp_up_training-internet-gateway" : "igw-0ac84600f1b39646e"

"ramp_up_training_private" : "rtb-0216df4cfc36e2f5a"
"ramp_up_training_public" : "rtb-0beec0658760f014a"

RDS
Las instancias deben corresponder a uno de los siguientes tipos
"*.small"
"*.micro"

EC2
 El instanceType debe ser :
"*.nano"
"*.small"
"*.micro"