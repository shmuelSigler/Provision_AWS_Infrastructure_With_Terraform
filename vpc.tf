
# Create VPCs in two different regions
resource "aws_vpc" "vpc_us_east" {
  cidr_block           = var.EAST
  provider             = aws.us-east
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
   tags = {
    Name = "east-VPC"
  }
}

resource "aws_vpc" "vpc_us_west" {
  cidr_block           = var.WEST
  provider             = aws.us-west
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "west-VPC"
  }
}

