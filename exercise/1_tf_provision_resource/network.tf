resource "aws_vpc" "kthw" {
  // Accessible via aws_vpc.kthw.cicd_block
  cidr_block = var.vpc_cidr

  // tags are used for identification, filtering querying, cost tracking and automation / policy
  // it's good practice to have tags for reasons above
  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

# How different resource attaches
# Rseources r made, then attached afterwards
# Why VPC does not have aws_internet_gateway.kthw.id inside it? 
# Because if like that, every new resource in vpc will have to go in there, which makes it hard to maintain
# So the smart programmar let us tag the VPC into the resources

// aws_internet_gateway is a real amazon resource
# Provide path between VPC & public internet (Sits at edge of VPC to perform)
# 1. Target for internet bound routes,
# 2. perform 1:1 NAT for instances that have public IPv4 addr (translate between instance private IP and public IP)
resource "aws_internet_gateway" "kthw" {
  // aws_vpc.kthw.id = reference to the VPC created above, is a value all resource have
  vpc_id = aws_vpc.kthw.id

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_subnet" "kthw" {
  vpc_id     = aws_vpc.kthw.id
  cidr_block = var.subnet_cidr
  # Matches my machines to public internet at launch
  map_public_ip_on_launch = true

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

# Determines where traffic destined for specific Ip get sent
resource "aws_route_table" "kthw" {
  vpc_id = aws_vpc.kthw.id

  # All cidr route to internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kthw.id
  }

  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

# Associate subnet to the route table, so that the subnet can use the route table to send traffic to the internet gateway
resource "aws_route_table_association" "kthw" {
  subnet_id      = aws_subnet.kthw.id
  route_table_id = aws_route_table.kthw.id
}
