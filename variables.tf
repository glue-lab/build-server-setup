
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
