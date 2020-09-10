variable "name_prefix" {
  description = "Name to prefix the VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR range of VPC"
  type        = string
}

variable "extra_tags" {
  description = "Estra tags that will be attached to the VPC"
  default     = {}
  type        = map(string)
}