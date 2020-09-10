# This module creates a basic VPC

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = merge(
    {
      "Name" = var.name_prefix
    },
    var.extra_tags,
  )
}
