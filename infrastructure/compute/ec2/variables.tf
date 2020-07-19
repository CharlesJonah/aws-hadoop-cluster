variable "key_name" {}

variable "instance_count" {
  type = number
}

variable "aws_ami" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}
variable "associate_public_ip_address" {
  type = bool
}

variable "common_tags" {}