variable "name_prefix" {
  description = "Prefix of resources"
  type        = string
  default     = "conekta"
}

variable "region" {
  description = "Region were VPC will be created"
  type        = string
  default     = "us-east-1"
}

variable "main_cidr" {
  description = "CIDR range of VPC. eg: 172.16.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "main_public_subnet_cidrs" {
  type        = list(string)
  description = "A list of public subnet CIDRs to deploy inside the VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "main_private_subnet_cidrs" {
  description = "A list of private subnet CIDRs to deploy inside the VPC. Should not be higher than public subnets count"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "support01_cidr" {
  description = "CIDR range of VPC. eg: 172.16.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "support01_public_subnet_cidrs" {
  type        = list(string)
  description = "A list of public subnet CIDRs to deploy inside the VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "support01_private_subnet_cidrs" {
  description = "A list of private subnet CIDRs to deploy inside the VPC. Should not be higher than public subnets count"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "support02_cidr" {
  description = "CIDR range of VPC. eg: 172.16.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "support02_public_subnet_cidrs" {
  type        = list(string)
  description = "A list of public subnet CIDRs to deploy inside the VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "support02_private_subnet_cidrs" {
  description = "A list of private subnet CIDRs to deploy inside the VPC. Should not be higher than public subnets count"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "extra_tags" {
  description = "Extra tags that will be added to VPC, DHCP Options, Internet Gateway, Subnets and Routing Table."
  type        = map(string)
  default     = {}
}