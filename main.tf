variable EAST {
  default = "10.0.0.0/16"
}

variable WEST {
  default = "10.1.0.0/16"
}

# Define providers for the two AWS regions
provider "aws" {
  alias  = "us-east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west"
  region = "us-west-1"
}

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


# Create two EC2 instances, one in each VPC
resource "aws_instance" "ec2_instance_us_east" {
  ami                  = "ami-0dbc3d7bc646e8516"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources-iam-profile.name
  subnet_id            = aws_subnet.subnet_us_east.id
  provider             = aws.us-east
  vpc_security_group_ids = [aws_security_group.allow_ping_east.id] 

  tags = {
    Name = "east"
  }
}

resource "aws_instance" "ec2_instance_us_west" {
  ami                  = "ami-0646513672e4fb341"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources-iam-profile.name
  subnet_id            = aws_subnet.subnet_us_west.id
  provider             = aws.us-west
  vpc_security_group_ids = [aws_security_group.allow_ping_west.id]
  tags = {
    Name = "west"
  }
}

# Security group for east instance
resource "aws_security_group" "allow_ping_east" {
  name        = "allow_ping_east"
  description = "Allow ping traffic"
  vpc_id      = aws_vpc.vpc_us_east.id
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.WEST]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = [var.EAST]
  }
  
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.WEST]
  }

  tags = {
    Name = "allow-ping-east"
  }
}

# Security group for west instance 
resource "aws_security_group" "allow_ping_west" {
  name        = "allow_ping_west"
  description = "Allow ping traffic"
  vpc_id      = aws_vpc.vpc_us_west.id
  provider    = aws.us-west
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.EAST]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = [var.WEST]
  }
  
  egress {
    from_port   = -1
    to_port     = -1 
    protocol    = "icmp"
    cidr_blocks = [var.EAST]
  }

  tags = {
    Name = "allow-ping-west" 
  }
}

# Create VPC Endpoints For Session Manager
resource "aws_security_group" "east_ssm_sg" {
  name        = "ssm-sg"
  vpc_id      = aws_vpc.vpc_us_east.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_us_east.cidr_block]
  }

}

resource "aws_security_group" "west_ssm_sg" {
  name        = "ssm-sg"
  vpc_id      = aws_vpc.vpc_us_west.id
  provider    = aws.us-west
  
  ingress {
    description = "HTTPS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_us_west.cidr_block]
  }
  
}

locals {
  endpoints = {
    "endpoint-ssm" = {
      name = "ssm"
    },
    "endpoint-ssmm-essages" = {
      name = "ssmmessages"
    },
    "endpoint-ec2-messages" = {
      name = "ec2messages"
    }
  }
}

resource "aws_vpc_endpoint" "east_endpoints" {
  vpc_id            = aws_vpc.vpc_us_east.id
  subnet_ids        = [aws_subnet.subnet_us_east.id]
  for_each          = local.endpoints
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.us-east-1.${each.value.name}"
  security_group_ids = [aws_security_group.east_ssm_sg.id]
  private_dns_enabled = true	# enabling DNS resolution allows to make requests to the service using its default DNS hostname

}

resource "aws_vpc_endpoint" "west_endpoints" {
  provider    = aws.us-west
  vpc_id            = aws_vpc.vpc_us_west.id
  subnet_ids        = [aws_subnet.subnet_us_west.id]
  for_each          = local.endpoints
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.us-west-1.${each.value.name}"
  security_group_ids = [aws_security_group.west_ssm_sg.id]
  private_dns_enabled = true

}


# IAM Role
resource "aws_iam_instance_profile" "resources-iam-profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.resources-iam-role.name
}

resource "aws_iam_role" "resources-iam-role" {
  name               = "ssm-role"
  description        = "The role for the resources EC2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resources-ssm-policy" {
  role       = aws_iam_role.resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
