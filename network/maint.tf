# Provider and region

provider "aws" {
  profile = "default"
  alias   = "conekta"
  region  = var.region
}

##########################
# Main VPC              ##
##########################

module "vpc" {
  source      = "../modules/vpc"
  cidr        = var.main_cidr
  name_prefix = "${var.name_prefix}-main"
  extra_tags  = var.extra_tags
}


##########################
# Main Private Subnets  ##
##########################

module "main-private-subnets" {
  source      = "../modules/subnets"
  vpc_id      = module.vpc.vpc_id
  public      = false
  name_prefix = "${var.name_prefix}-main-private"
  cidr_blocks = var.main_private_subnet_cidrs
  extra_tags  = var.extra_tags
}

##########################
# Main Public Subnets   ##
##########################


module "main-public-subnets" {
  source      = "../modules/subnets"
  vpc_id      = module.vpc.vpc_id
  name_prefix = "${var.name_prefix}-public"
  cidr_blocks = var.main_public_subnet_cidrs
  extra_tags  = var.extra_tags
}

##########################
# Main Internet Gateway ##
##########################

resource "aws_internet_gateway" "main-igw" {

  vpc_id = module.vpc.vpc_id

  tags = merge(
    {
      Name = format("%s-IGW", var.name_prefix)
    },
    var.extra_tags
  )
}

##########################
# Main NAT Gateway      ##
##########################

resource "aws_eip" "main-nat-eip" {
  vpc = true

  depends_on = [aws_internet_gateway.main-igw]
}

resource "aws_nat_gateway" "main-nat-gw" {
  allocation_id = aws_eip.main-nat-eip.id
  subnet_id     = element(module.main-public-subnets.ids, 0)

  depends_on = [aws_internet_gateway.main-igw]
}

##########################
# Main Route Tables     ##
##########################

resource "aws_route_table" "private" {

  vpc_id = module.vpc.vpc_id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-private-main"
    },
    var.extra_tags,
  )
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main-nat-gw.id
}

resource "aws_route" "private_peer-sup01" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01.id
}

resource "aws_route" "private_peer-sup02" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup02.id
}

resource "aws_route_table_association" "private-rta" {
  count          = length(module.main-private-subnets.ids)
  subnet_id      = element(module.main-private-subnets.ids, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-main"
    },
    var.extra_tags,
  )
}

resource "aws_route_table_association" "public" {
  count          = length(module.main-public-subnets.ids)
  subnet_id      = element(module.main-public-subnets.ids, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_peer-sup02" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup02.id
}


resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
  depends_on             = [aws_route_table.public]
}

##########################
# Support01 VPC         ##
##########################

module "vpc-support01" {
  source      = "../modules/vpc"
  cidr        = var.support01_cidr
  name_prefix = "${var.name_prefix}-support01"
  extra_tags  = var.extra_tags
}

##########################
# Support01 Subnets     ##
##########################

module "support01-private-subnets" {
  source      = "../modules/subnets"
  vpc_id      = module.vpc-support01.vpc_id
  public      = false
  name_prefix = "${var.name_prefix}-sup01-private"
  cidr_blocks = var.support01_private_subnet_cidrs
  extra_tags  = var.extra_tags
}

#############################
# Support01 Public Subnets ##
#############################

module "support01-public-subnets" {
  source      = "../modules/subnets"
  vpc_id      = module.vpc-support01.vpc_id
  name_prefix = "${var.name_prefix}-sup01-public"
  cidr_blocks = var.support01_public_subnet_cidrs
  extra_tags  = var.extra_tags
}

resource "aws_internet_gateway" "sup01-igw" {

  vpc_id = module.vpc-support01.vpc_id

  tags = merge(
    {
      Name = format("%s-sup01-IGW", var.name_prefix)
    },
    var.extra_tags
  )
}

##########################
# Support01 NAT GW      ##
##########################

resource "aws_eip" "sup01-nat-eip" {
  vpc = true

  depends_on = [aws_internet_gateway.sup01-igw]
}

resource "aws_nat_gateway" "sup01-nat-gw" {
  allocation_id = aws_eip.sup01-nat-eip.id
  subnet_id     = element(module.support01-public-subnets.ids, 0)

  depends_on = [aws_internet_gateway.sup01-igw]
}


###########################
# Support01 Route Tables ##
###########################

resource "aws_route_table" "private-sup01" {

  vpc_id = module.vpc-support01.vpc_id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-private-sup01"
    },
    var.extra_tags,
  )
}

resource "aws_route" "private_nat_gateway-sup01" {
  route_table_id         = aws_route_table.private-sup01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.sup01-nat-gw.id
}

resource "aws_route" "private_peer-sup01-main" {
  route_table_id            = aws_route_table.private-sup01.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01.id
  depends_on                = [aws_route_table.private-sup01]
}

resource "aws_route" "private_peer-sup01-sup02" {
  route_table_id            = aws_route_table.private-sup01.id
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01-02.id
  depends_on                = [aws_route_table.private-sup01]
}

resource "aws_route_table_association" "private-sup01-rta" {
  count          = length(module.support01-private-subnets.ids)
  subnet_id      = element(module.support01-private-subnets.ids, count.index)
  route_table_id = element(aws_route_table.private-sup01.*.id, count.index)
}

resource "aws_route_table" "public-sup01" {
  vpc_id = module.vpc-support01.vpc_id
  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-sup01"
    },
    var.extra_tags,
  )
}

resource "aws_route" "public_peer-sup01-sup02" {
  route_table_id            = aws_route_table.public-sup01.id
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01-02.id
  depends_on                = [aws_route_table.private-sup01]
}

resource "aws_route" "public-sup01" {
  route_table_id         = aws_route_table.public-sup01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sup01-igw.id
  depends_on             = [aws_route_table.public-sup01]
}

resource "aws_route_table_association" "public-sup01" {
  count          = length(module.support01-public-subnets.ids)
  subnet_id      = element(module.support01-public-subnets.ids, count.index)
  route_table_id = aws_route_table.public-sup01.id
}

##########################
# Support02 VPC         ##
##########################

module "vpc-support02" {
  source      = "../modules/vpc"
  cidr        = var.support02_cidr
  name_prefix = "${var.name_prefix}-support02"
  extra_tags  = var.extra_tags
}

##########################
# Support02 Subnets         ##
##########################

module "support02-private-subnets" {
  source      = "../modules/subnets"
  vpc_id      = module.vpc-support02.vpc_id
  public      = false
  name_prefix = "${var.name_prefix}-sup02-private"
  cidr_blocks = var.support02_private_subnet_cidrs
  extra_tags  = var.extra_tags
}

module "support02-public-subnets" {
  source      = "../modules/subnets"
  vpc_id      = module.vpc-support02.vpc_id
  name_prefix = "${var.name_prefix}-sup02-public"
  cidr_blocks = var.support02_public_subnet_cidrs
  extra_tags  = var.extra_tags
}

##########################
# Support02 IGW         ##
##########################

resource "aws_internet_gateway" "sup02-igw" {

  vpc_id = module.vpc-support02.vpc_id

  tags = merge(
    {
      Name = format("%s-sup02-IGW", var.name_prefix)
    },
    var.extra_tags
  )
}

resource "aws_eip" "support02-nat-eip" {
  vpc = true

  depends_on = [aws_internet_gateway.sup02-igw]
}

##########################
# Support02 NAT         ##
##########################

resource "aws_nat_gateway" "sup02-nat-gw" {
  allocation_id = aws_eip.support02-nat-eip.id
  subnet_id     = element(module.support02-public-subnets.ids, 0)

  depends_on = [aws_internet_gateway.sup02-igw]
}

##########################
# Support02 RTB         ##
##########################

resource "aws_route_table" "private-sup02" {

  vpc_id = module.vpc-support02.vpc_id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-private-sup02"
    },
    var.extra_tags,
  )
}

resource "aws_route" "private_nat_gateway-sup02" {
  route_table_id         = aws_route_table.private-sup02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.sup02-nat-gw.id
}

resource "aws_route" "private_peer-sup02-main" {
  route_table_id            = aws_route_table.private-sup02.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup02.id
  depends_on                = [aws_route_table.private-sup02]
}

resource "aws_route" "private_peer-sup02-sup01" {
  route_table_id            = aws_route_table.private-sup02.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01-02.id
  depends_on                = [aws_route_table.private-sup02]
}

resource "aws_route_table_association" "private-sup02-rta" {
  count          = length(module.support02-private-subnets.ids)
  subnet_id      = element(module.support02-private-subnets.ids, count.index)
  route_table_id = element(aws_route_table.private-sup02.*.id, count.index)
}

resource "aws_route_table" "public-sup02" {
  vpc_id = module.vpc-support02.vpc_id
  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-sup02"
    },
    var.extra_tags,
  )
}

resource "aws_route" "public-sup02" {
  route_table_id         = aws_route_table.public-sup02.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sup02-igw.id
  depends_on             = [aws_route_table.public-sup02]
}

resource "aws_route_table_association" "public-sup02" {
  count          = length(module.support02-public-subnets.ids)
  subnet_id      = element(module.support02-public-subnets.ids, count.index)
  route_table_id = aws_route_table.public-sup02.id
}

##########################
# VPC Peering           ##
##########################

# From Main to Support01

resource "aws_vpc_peering_connection" "peer-sup01" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = module.vpc-support01.vpc_id
  peer_region = var.region
  auto_accept = false
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer-sup01" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01.id
  auto_accept               = true
}

# From Main to Support02

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer-sup02" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = module.vpc-support02.vpc_id
  peer_region = var.region
  auto_accept = false
}

resource "aws_vpc_peering_connection_accepter" "peer-sup02" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup02.id
  auto_accept               = true
}

# From Support01 to Support02

resource "aws_vpc_peering_connection" "peer-sup01-02" {
  vpc_id      = module.vpc-support01.vpc_id
  peer_vpc_id = module.vpc-support02.vpc_id
  peer_region = var.region
  auto_accept = false
}

resource "aws_vpc_peering_connection_accepter" "peer-sup01-02" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer-sup01-02.id
  auto_accept               = true
}