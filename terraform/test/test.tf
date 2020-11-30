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

resource "aws_instance" "quotes-test" {
  ami                  = "ami-069098bd859abd964"
  instance_type        = "t2.micro"
  key_name             = "dan16"
  security_groups      = ["tfQuotesSGNodeJS3000"]
  iam_instance_profile = "tfQuotesEC2Profile"
  # user_data          = <<EOF EOF

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/lib/quotes",
      "cd /var/lib/quotes",
      "sudo yum install jq -y",
      "sudo aws s3 cp s3://dan16-quote-bucket/deployment.tar.gz .",
      "sudo tar -xvf deployment.tar.gz",
      "sudo rm deployment.tar.gz",
      "cd ./data",
      "sudo aws s3 cp s3://dan16-quote-bucket/quotes_all.csv.gpg .",
      "sudo gpg --batch --yes --passphrase \"$${AWS_SECRET}${var.GH_SECRET}\" -o quotes_all.csv --pinentry loopback -d quotes_all.csv.gpg",
      "export AWS_SECRET=$(aws secretsmanager get-secret-value --secret-id quotes/db/pass --region us-east-1 --query SecretString --output text | jq -r .db_encryption_pass)",
      "echo \"$${AWS_SECRET}${var.GH_SECRET}\" > /home/ec2-user/asdf.txt",
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

# data "aws_secretsmanager_secret" "gpg" {
#   name = "quotes/db/pass"
# }

# data "aws_secretsmanager_secret_version" "example" {
#   secret_id = data.aws_secretsmanager_secret.gpg.id
# }

# output "tester" {
#   value = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["db_encryption_pass"]
# }

# output "tester2" {
#   value = var.GH_SECRET
# }