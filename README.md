# TerraformAWSInfra

## Infraestructure

![alt text](./CloudInfra.png)

## How to

Having Terraform installed. Run:

> terraform plan

> terraform apply


For auto-approve run:

> terraform apply -auto-approve

or

> terraform destroy -auto-approve

## Debug Bastion Host - CI Test

Sometimes you just need to provison only the BastionHost to do CI tests or other issues. If that's the case take the bastionHost.DEBUG file and move it to a new folder. Rename it as bastionHost.tf and run the following commands inside the new folder:


> terraform init

> terraform plan

> terraform apply

Note: This does not provision database, UI or API.