
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
