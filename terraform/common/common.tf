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

resource "aws_iam_role" "tfQuotesEC2S3Role" {
  name               = "tfQuotesEC2S3Role"
  assume_role_policy = file("aws-policy-ec2-assume-role.json")
}

resource "aws_iam_instance_profile" "tfQuotesEC2S3Profile" {
  name = "tfQuotesEC2S3Profile"
  role = aws_iam_role.tfQuotesEC2S3Role.name
}

resource "aws_iam_policy" "tfQuotesEC2S3Policy" {
  name        = "tfQuotesEC2S3Policy"
  description = "A test policy"
  policy      = file("aws-policy-s3-bucket.json")
}

resource "aws_iam_policy_attachment" "tfQuotesEC2S3Attach" {
  name       = "tfQuotesEC2S3Attach"
  roles      = [aws_iam_role.tfQuotesEC2S3Role.name]
  policy_arn = aws_iam_policy.tfQuotesEC2S3Policy.arn
}

resource "aws_eip" "tfQuotesEIP" {
    tags = {
        server = "quotes"
    }
}