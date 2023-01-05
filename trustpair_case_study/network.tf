# Create VPC for public REST API
resource "aws_vpc" "euw_api_vpc" {
  cidr_block = "10.100.0.0/16"
  tags = {
    Name = "Trustpair - API Project VPC"
  }
}

# Creating public subnets inside REST API VPC 
resource "aws_subnet" "euw_api_public_subnets" {
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.euw_api_vpc.id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.availability_zones, count.index)
 
 tags = {
   Name = "eu-west-${count.index + 1}_public_subnet_${count.index + 1}"
 }
}

# Creating private subnets inside REST API VPC 
resource "aws_subnet" "euw_api_private_subnet" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.euw_api_vpc.id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.availability_zones, count.index)
 
 tags = {
   Name = "eu-west-${count.index + 1}_private_subnet_${count.index + 1}"
 }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.euw_api_vpc.id
}


### Public ROUTE for each public subnet
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.euw_api_vpc.id
  count  = length(var.public_subnet_cidrs)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

### ROUTE association for each public subnet
resource "aws_route_table_association" "route_table_association_public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.euw_api_public_subnets[count.index].id
  route_table_id = aws_route_table.route_table_public[count.index].id
}


### Elastic IP for each public subnet
resource "aws_eip" "eip" {
  count      = length(var.public_subnet_cidrs)
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

### NAT GW foreach EIP of public subnets
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.euw_api_public_subnets[count.index].id
}

### Private ROUTE to PUBLIC NAT GW for private subnets
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.euw_api_vpc.id
  count          = length(var.private_subnet_cidrs)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
}

### ROUTE association for each private subnet
resource "aws_route_table_association" "route_table_association_private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.euw_api_private_subnet[count.index].id
  route_table_id = aws_route_table.route_table_private[count.index].id
}