# main.tf

provider "aws" {
  region = "us-east-2"
  profile = "work"
}

resource "aws_instance" "build_server" {
  ami           = "ami-04f167a56786e4b09"
  instance_type = "t2.micro"

  tags = {
    Name = "BuildServer"
  }
}
