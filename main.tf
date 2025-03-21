# main.tf

provider "aws" {
  region = "us-east-2"
  profile = var.aws_profile
}

resource "aws_instance" "build_server" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
