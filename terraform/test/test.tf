terraform {
  backend "s3" {
    bucket = "dan16-quote-bucket"
    key    = "tf/test/state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "GH_SECRET" {
  type = string
}

data "aws_secretsmanager_secret" "gpg" {
  name = "quotes/db/pass"
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = data.aws_secretsmanager_secret.gpg.id
}

resource "aws_instance" "quotes-test" {
  ami                  = "ami-069098bd859abd964"
  instance_type        = "t2.micro"
  key_name             = "dan16"
  security_groups      = ["tfQuotesSGNodeJS3000"]
  iam_instance_profile = "tfQuotesEC2S3Profile"
  # user_data          = <<EOF EOF

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/lib/quotes",
      "cd /var/lib/quotes",
      "sudo aws s3 cp s3://dan16-quote-bucket/deployment.tar.gz .",
      "sudo tar -xvf deployment.tar.gz",
      "sudo rm deployment.tar.gz",
      "echo '${jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["db_encryption_pass"]}${var.GH_SECRET}' > /home/ec2-user/asdf.txt",
      "echo '${file("../common/systemd-quotes.service")}' | sudo tee /etc/systemd/system/quotes.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable quotes.service",
      "sudo systemctl start quotes.service"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  tags = {
    name = "quotes-test"
  }
}

output "instance_ip_addr" {
  value = aws_instance.quotes-test.public_ip
}

output "tester" {
  value = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["db_encryption_pass"]
}

output "tester2" {
  value = var.GH_SECRET
}
