
variable "aws_profile" {
  description = "Profile to use from ~/.aws/credentials"
  type        = string
}

variable "instance_ami" {
  description = "ID for the build server AMI (format ami-xxxxx...)"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to create (ex. m5.large)"
  type        = string
}

variable "instance_name" {
  description = "The name to associate with this build server"
  type        = string
}

variable "key_name" {
  description = "The name of the AWS EC2 key pair to use for SSH access"
  type        = string
}

variable "my_public_ip" {
  description = "Your public IP address"
  type        = string
}

variable "snapshot_id" {
  description = "ID of snapshot to initialize the data drive from"
  type        = string
}

variable "data_drive_size" {
  description = "Size of the data drive in gigabytes (GB)"
  type        = number
}

variable "db_server_sg_id" {
  description = "The ID of the DB server's security group"
  type        = string
}

variable "db_port" {
  description = "The port that the database is listening on"
  type        = number
}
