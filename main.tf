# main.tf

provider "aws" {
  region = "us-east-2"
  profile = var.aws_profile
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "build_server_access" {
  name        = var.instance_name
  description = "Control access to build server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Build server owner"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "build_server" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.build_server_access.id]

  tags = {
    Name = var.instance_name
  }
}

resource "aws_ebs_volume" "data_drive" {
  availability_zone = aws_instance.build_server.availability_zone
  snapshot_id       = var.snapshot_id
  size              = var.data_drive_size

  tags = {
    Name = "${var.instance_name}-data"
  }
}

resource "aws_volume_attachment" "data_drive_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data_drive.id
  instance_id  = aws_instance.build_server.id
}

output "instance_public_ip" {
  description = "Public IP of the build server"
  value       = aws_instance.build_server.public_ip
}
