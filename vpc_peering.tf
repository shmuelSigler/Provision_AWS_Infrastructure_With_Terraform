
# VPC peering between east to west
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_owner_id = "195122422785"
  peer_vpc_id   = aws_vpc.vpc_us_west.id
  vpc_id        = aws_vpc.vpc_us_east.id
  peer_region   = "us-west-1"
  auto_accept   = false 	

  tags = {
    Name = "VPC Peering between east and west"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.us-west
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}
