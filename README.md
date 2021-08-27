# terraform-network

This creates:

* 3 VPCs with two or more subnets defined on terraform.tfvars
* NAT Gateway 
* Internet Gateway
* VPC Peerings from vpc-1 to vpc-2 and from vpc-2 to vpc-3 (non-transitive)
* Route tables needed
