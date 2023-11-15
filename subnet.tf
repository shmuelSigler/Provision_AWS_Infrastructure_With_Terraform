
# Create subnets in the VPCs
resource "aws_subnet" "subnet_us_east" {
  vpc_id                  = aws_vpc.vpc_us_east.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  provider                = aws.us-east
}

resource "aws_subnet" "subnet_us_west" {
  vpc_id                  = aws_vpc.vpc_us_west.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
  provider                = aws.us-west
}

# East components
resource "aws_route_table" "east-pub-RT" {
  vpc_id = aws_vpc.vpc_us_east.id
  
  route {
    cidr_block = var.WEST
    gateway_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "east-pub-RT"
  }
}

resource "aws_route_table_association" "east-pub-1-a" {
  subnet_id      = aws_subnet.subnet_us_east.id
  route_table_id = aws_route_table.east-pub-RT.id
}

# West components
resource "aws_route_table" "west-pub-RT" {
  vpc_id = aws_vpc.vpc_us_west.id
  provider = aws.us-west
  
  route {
    cidr_block = var.EAST
    gateway_id = aws_vpc_peering_connection.vpc_peering.id
  }

  tags = {
    Name = "west-pub-RT"
  }
}

resource "aws_route_table_association" "west-pub-1-a" {
  subnet_id      = aws_subnet.subnet_us_west.id
  route_table_id = aws_route_table.west-pub-RT.id
  provider = aws.us-west
}
