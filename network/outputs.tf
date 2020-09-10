output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC id"
}

output "public_cidr_blocks" {
  value       = module.main-public-subnets.cidr_blocks
  description = "List of public subnet CIDR blocks"
}

output "private_cidr_blocks" {
  value       = module.main-private-subnets.cidr_blocks
  description = "List of private subnet CIDR blocks"
}

output "public_subnet_ids" {
  value       = module.main-public-subnets.ids
  description = "List of public subnet ids"
}

output "private_subnet_ids" {
  value       = module.main-private-subnets.ids
  description = "List of private subnet ids. None created if list is empty."
}
