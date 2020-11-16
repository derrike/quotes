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

resource "aws_instance" "quotes-test" {
  ami                  = "ami-069098bd859abd964"
  instance_type        = "t2.micro"
  key_name             = "dan16"
  security_groups      = ["ssh3000"]
  iam_instance_profile = "tfQuotesEC2S3Profile"

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/lib/quotes",
      "cd /var/lib/quotes",
      "sudo aws s3 cp s3://dan16-quote-bucket/deployment.tar.gz .",
      "sudo tar -xvf deployment.tar.gz",
      "sudo rm deployment.tar.gz",
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
  value = aws_instance.test.public_ip
}
