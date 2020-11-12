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

# variable "ssh_private_key" {
#   type = string
#   description = "the ssh key to aws instance"
# }

resource "aws_instance" "test" {
  ami                  = "ami-069098bd859abd964"
  instance_type        = "t2.micro"
  key_name             = "dan16"
  security_groups      = ["ssh3000"]
  iam_instance_profile = "tfQuotesEC2S3Profile"
  # user_data            = <<EOF
  #   #!/bin/bash
  #   mkdir /var/lib/quotes
  #   cd /var/lib/quotes
  #   aws s3 cp s3://dan16-quote-bucket/deployment.tar.gz .
  #   tar -xvf deployment.tar.gz
  #   rm deployment.tar.gz
  #   echo "${file("../common/systemd-quotes.service")}" > /lib/systemd/system/quotes.service
  #   systemctl daemon-reload
  #   systemctl enable quotes.service
  #   systemctl start quotes.service
  # EOF



  provisioner "remote-exec" {
    inline = [ "echo 'connected!" ]

    # inline = [
    #   "sudo mkdir /var/lib/quotes",
    #   "cd /var/lib/quotes",
    #   "sudo aws s3 cp s3://dan16-quote-bucket/deployment.tar.gz .",
    #   "sudo tar -xvf deployment.tar.gz",
    #   "sudo rm deployment.tar.gz",
    #   "echo '${file("../common/systemd-quotes.service")}' | sudo tee /lib/systemd/system/quotes.service",
    #   "sudo systemctl daemon-reload",
    #   "sudo systemctl enable quotes.service",
    #   "sudo systemctl start quotes.service"
    # ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      # private_key = var.ssh_private_key
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ec2-user -i ${self.public_ip}, ../ansible/playbook.yml"
  }

  tags = {
    name = "quotes-test"
  }
}

output "instance_ip_addr" {
  value = aws_instance.test.public_ip
}
