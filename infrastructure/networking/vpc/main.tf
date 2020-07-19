#VPC
resource "aws_vpc" "aws-hadoop-cluster-vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = var.common_tags
}

# SUBNETS
resource "aws_subnet" "aws-hadoop-cluster-private-subnet-1" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  cidr_block = var.private_subnet_1
  availability_zone = var.availability_zone_us_east_1a
}

resource "aws_subnet" "aws-hadoop-cluster-public-subnet-1" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  cidr_block = var.public_subnet_1
  availability_zone = var.availability_zone_us_east_1a
}

resource "aws_subnet" "aws-hadoop-cluster-private-subnet-2" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  cidr_block = var.private_subnet_2
  availability_zone = var.availability_zone_us_east_1b
}

resource "aws_subnet" "aws-hadoop-cluster-public-subnet-2" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  cidr_block = var.public_subnet_2
  availability_zone = var.availability_zone_us_east_1b
}


#INTERNET GATEWAY
resource "aws_internet_gateway" "aws-hadoop-cluster-igw" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  tags = var.common_tags
}

#ELASTIC IP
resource "aws_eip" "nat_eip" {
  vpc      = true
  depends_on = [aws_internet_gateway.aws-hadoop-cluster-igw]
}

#NAT GATEWAY
resource "aws_nat_gateway" "aws-hadoop-cluster-nat-gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.aws-hadoop-cluster-public-subnet-1.id}"
  depends_on = [aws_internet_gateway.aws-hadoop-cluster-igw]
}

#ROUTE TABLES
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  tags = var.common_tags

}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.aws-hadoop-cluster-vpc.id}"
  tags = var.common_tags

}

#ROUTES
resource "aws_route" "public_route" {
	route_table_id  = "${aws_route_table.public_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.aws-hadoop-cluster-igw.id}"
}

resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.aws-hadoop-cluster-nat-gw.id}"
}

#ROUTE TABLE ASSOCIATIONS
resource "aws_route_table_association" "public_route_table_assoc_1" {
  subnet_id      = "${aws_subnet.aws-hadoop-cluster-public-subnet-1.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_route_table_assoc_2" {
  subnet_id      = "${aws_subnet.aws-hadoop-cluster-public-subnet-2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private_route_table_assoc_1" {
  subnet_id      = "${aws_subnet.aws-hadoop-cluster-private-subnet-1.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_route_table_assoc_2" {
  subnet_id      = "${aws_subnet.aws-hadoop-cluster-private-subnet-2.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}


##security groups
##instances

## Refactor to use for_each and each and count