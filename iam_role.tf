
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
