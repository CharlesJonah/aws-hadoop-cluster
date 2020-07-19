# VARIABLES
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {
    default = "us-east-1"
}

variable "cidr" {
    type = map(string)
}

variable "bastion_ingress_cidr" {
    type = list(string)
}


variable "availability_zones" {
    type = map(list(string))
}

variable "private_subnets" {
    type = map(list(string))
}

variable "public_subnets" {
    type = map(list(string))
}

variable "key_name" {}

variable "public_key_path" {}

#LOCALS

locals {
  common_tags = {
        ENVIRONMENT_NAME = lower(terraform.workspace)
    }
}
