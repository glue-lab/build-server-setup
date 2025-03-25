# main.tf

provider "aws" {
  region = "us-east-2"
  profile = var.aws_profile
}

provider "random" {
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

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_integer" "pick" {
  min = 0
  max = length(data.aws_subnets.default_vpc_subnets.ids) - 1
}

locals {
  selected_subnet_id = element(data.aws_subnets.default_vpc_subnets.ids, random_integer.pick.result)
}

data "aws_subnet" "selected" {
  id = local.selected_subnet_id
}

resource "aws_instance" "build_server" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.build_server_access.id]

  user_data = <<-EOF
              #!/bin/bash

              # Capture standard out and standard error
              exec > /var/log/user-data.log 2>&1

              # Fail on error
              set -eux

              # Identify data drive by volume ID
              DATA_VOLUME_ID="${aws_ebs_volume.data_drive.id}"
              DEVICE_PATH="/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_$${DATA_VOLUME_ID//-/}_1"

              # Mount this drive to /var/lib/postgresql, adding to /etc/fstab for stop/start
              mkdir -p /var/lib/postgresql
              echo "$${DEVICE_PATH} /var/lib/postgresql ext4 defaults,nofail 0 2" >> /etc/fstab
              mount -a

              # Ensure the drive is using all available space
              resize2fs "$${DEVICE_PATH}"
              EOF

  tags = {
    Name = var.instance_name
  }
}

resource "aws_ebs_volume" "data_drive" {
  availability_zone = data.aws_subnet.selected.availability_zone
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

data "aws_security_group" "db_server" {
  id = var.db_server_sg_id
}

resource "aws_security_group_rule" "allow_ssh_from_instance" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.build_server.public_ip}/32"]
  security_group_id = data.aws_security_group.db_server.id
  description       = var.instance_name
}

output "instance_public_ip" {
  description = "Public IP of the build server"
  value       = aws_instance.build_server.public_ip
}
