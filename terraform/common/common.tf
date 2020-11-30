terraform {
  backend "s3" {
    bucket = "dan16-quote-bucket"
    key    = "tf/common/state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "tfQuotesEC2Role" {
  name               = "tfQuotesEC2Role"
  assume_role_policy = file("aws-policy-ec2-assume-role.json")
}

resource "aws_iam_instance_profile" "tfQuotesEC2Profile" {
  name = "tfQuotesEC2Profile"
  role = aws_iam_role.tfQuotesEC2Role.name
}

resource "aws_iam_policy" "tfQuotesEC2Policy" {
  name        = "tfQuotesEC2Policy"
  description = "A test policy"
  policy      = file("aws-policy-ec2-quotes.json")
}

resource "aws_iam_policy_attachment" "tfQuotesEC2Attach" {
  name       = "tfQuotesEC2Attach"
  roles      = [aws_iam_role.tfQuotesEC2Role.name]
  policy_arn = aws_iam_policy.tfQuotesEC2Policy.arn
}

resource "aws_security_group" "tfQuotesSGNodeJS3000" {
  name        = "tfQuotesSGNodeJS3000"
  description = "Allow port 3000 for node web app"

  ingress {
    description = "Port 3000 for Node Web App"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "tfQuotesEIP" {
    tags = {
        server = "quotes"
    }
}
