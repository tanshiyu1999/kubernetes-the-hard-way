resource "aws_vpc" "kthw" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_internet_gateway" "kthw" {
  vpc_id = aws_vpc.kthw.id

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_subnet" "kthw" {
  vpc_id                  = aws_vpc.kthw.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_route_table" "kthw" {
  vpc_id = aws_vpc.kthw.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kthw.id
  }

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_route_table_association" "kthw" {
  subnet_id      = aws_subnet.kthw.id
  route_table_id = aws_route_table.kthw.id
}
