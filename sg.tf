
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
