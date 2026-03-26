/*
 * # AWS vpc secondary cidr module
 * Terraform module which creates SAF2.0 VPC Secondary cidr in AWS.
*/
#
#  Filename    : aws/modules/vpc/secondary-cidr/main.tf
#  Date        : 19 AUGUEST 2025
#  Author      : SUKX/E6BO
#  Description : This terraform module creates a secondary cidr.

/*
 * # RFC 6598 CIDR Overlay
 * Adds secondary CIDR to existing VPC
*/

resource "aws_vpc_ipv4_cidr_block_association" "rfc6598_cidr" {
  count      = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id     = data.aws_ssm_parameter.vpc_id.value
  cidr_block = var.parameter_sec_vpc_cidr
}

resource "aws_subnet" "subnet_a" {
  count                = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id               = aws_vpc_ipv4_cidr_block_association.rfc6598_cidr[count.index].vpc_id
  cidr_block           = var.subnet_a_cidr
  availability_zone_id = "usw2-az1"
  tags = merge(
    var.tags,
    { Name = "${var.subnet_a_name}"
    Access = "VPC-only" }
  )
}

resource "aws_subnet" "subnet_b" {
  count                = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id               = aws_vpc_ipv4_cidr_block_association.rfc6598_cidr[count.index].vpc_id
  cidr_block           = var.subnet_b_cidr
  availability_zone_id = "usw2-az2"
  tags = merge(
    var.tags,
    { Name = "${var.subnet_b_name}"
    Access = "VPC-only" }
  )
}

resource "aws_subnet" "subnet_c" {
  count                = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id               = aws_vpc_ipv4_cidr_block_association.rfc6598_cidr[count.index].vpc_id
  cidr_block           = var.subnet_c_cidr
  availability_zone_id = "usw2-az3"
  tags = merge(
    var.tags,
    { Name = "${var.subnet_b_name}"
    Access = "VPC-only" }
  )
}

# Route Tables
resource "aws_route_table" "az_a" {
  count  = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_ssm_parameter.parameter_transit_gateway.value
  }

  lifecycle {
    ignore_changes = all
  }

  tags = merge(
    var.tags,
    { Name = "subnet_azA"
    }
  )
}

resource "aws_route_table" "az_b" {
  count  = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_ssm_parameter.parameter_transit_gateway.value
  }

  lifecycle {
    ignore_changes = all
  }

  tags = merge(
    var.tags,
    { Name = "subnet_azB"
    }
  )
}

resource "aws_route_table" "az_c" {
  count  = var.create_vpc_sec_cidr ? 1 : 0
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_ssm_parameter.parameter_transit_gateway.value
  }

  lifecycle {
    ignore_changes = all
  }

  tags = merge(
    var.tags,
    { Name = "subnet_azC"
    }
  )
}

# Route Table Subnet Associations

resource "aws_route_table_association" "az_a" {
  count          = var.create_vpc_sec_cidr ? 1 : 0
  subnet_id      = aws_subnet.subnet_a[count.index].id
  route_table_id = aws_route_table.az_a[count.index].id
}

resource "aws_route_table_association" "az_b" {
  count          = var.create_vpc_sec_cidr ? 1 : 0
  subnet_id      = aws_subnet.subnet_b[count.index].id
  route_table_id = aws_route_table.az_b[count.index].id
}

resource "aws_route_table_association" "az_c" {
  count          = var.create_vpc_sec_cidr ? 1 : 0
  subnet_id      = aws_subnet.subnet_c[count.index].id
  route_table_id = aws_route_table.az_c[count.index].id
}

resource "aws_ssm_parameter" "subnet_ida" {
  count = var.create_vpc_sec_cidr ? 1 : 0

  name  = var.parameter_subnet_ida
  type  = "String"
  value = aws_subnet.subnet_a[0].id

  tags = var.tags
}

resource "aws_ssm_parameter" "subnet_idb" {
  count = var.create_vpc_sec_cidr ? 1 : 0

  name  = var.parameter_subnet_idb
  type  = "String"
  value = aws_subnet.subnet_b[0].id

  tags = var.tags
}

resource "aws_ssm_parameter" "subnet_idc" {
  count = var.create_vpc_sec_cidr ? 1 : 0

  name  = var.parameter_subnet_idc
  type  = "String"
  value = aws_subnet.subnet_c[0].id

  tags = var.tags
}

