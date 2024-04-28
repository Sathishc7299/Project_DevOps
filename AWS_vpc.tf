provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
