
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
