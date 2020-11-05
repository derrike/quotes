terraform {
  backend "s3" {
    bucket = "dan16-quote-bucket"
    key    = "tf/prod/state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prod" {
  ami                  = "ami-069098bd859abd964"
  instance_type        = "t2.micro"
  key_name             = "dan16"
  security_groups      = ["ssh3000"]
  iam_instance_profile = "tfQuotesEC2S3Profile"
  user_data            = <<EOF
    #!/bin/bash
    mkdir /var/lib/quotes
    cd /var/lib/quotes
    aws s3 cp s3://dan16-quote-bucket/deployment.tar.gz .
    tar -xvf deployment.tar.gz
    rm deployment.tar.gz
    echo "${file("../common/systemd-quotes.service")}" > /lib/systemd/system/quotes.service
    systemctl daemon-reload
    systemctl enable quotes.service
    systemctl start quotes.service
  EOF

  tags = {
    name = "quotes-test"
  }
}

data "aws_eip" "quotes_eip" {
  filter {
    name = "tag:server"
    values = ["quotes"]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.prod.id
  allocation_id = data.aws_eip.quotes_eip.id
}

output "instance_ip_addr" {
  value = data.aws_eip.quotes_eip.public_ip
}