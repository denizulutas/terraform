provider "aws" {
  region  = "us-east-1"
//  profile = "cw-training"
}
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "example" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
//  key_name        = "northvirginia"
  count           = 2
  security_groups = ["tf-assignment"]
  user_data       = <<-EOF
                  #! /bin/bash
                  sudo su
                  yum -y install httpd
                  echo "<p> Hello World </p>" >> /var/www/html/index.html
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF
  tags = {
    Name = "terraform ${element(var.mytags, count.index)} instance"
  }
    provisioner "local-exec" {
      command = "echo ${self.private_ip} >> private.txt"
    }
    provisioner "local-exec" {
      command = "echo ${self.public_ip} >> public.txt"
    }
}
resource "aws_security_group" "security" {
  name = "tf-assignment"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
variable "mytags" {
  type    = list(string)
  default = ["first", "second"]
}
output "mypublicip" {
  value = aws_instance.example[*].public_ip
}
