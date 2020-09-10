# This module creates one or more subnets

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "main" {
  count             = length(var.cidr_blocks)
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      "Name" = "${var.name_prefix}-${format("%02d", count.index + 1)}-${data.aws_availability_zones.available.names[count.index]}"
    },
    var.extra_tags,
  )

  map_public_ip_on_launch = var.public
}
