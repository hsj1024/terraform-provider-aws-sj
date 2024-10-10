# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "rookies_final" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "rookies_final-eks-node",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_subnet" "rookies_final" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.rookies_final.id

  tags = tomap({
    "Name"                                      = "rookies_final-eks-node",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_internet_gateway" "rookies_final" {
  vpc_id = aws_vpc.rookies_final.id

  tags = {
    Name = "rookies_final-eks"
  }
}

resource "aws_route_table" "rookies_final" {
  vpc_id = aws_vpc.rookies_final.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rookies_final.id
  }
}

resource "aws_route_table_association" "rookies_final" {
  count = 2

  subnet_id      = aws_subnet.rookies_final.*.id[count.index]
  route_table_id = aws_route_table.rookies_final.id
}
