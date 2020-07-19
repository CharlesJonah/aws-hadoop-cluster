#COMMON
variable "common_tags" {}

# VPC
variable "cidr" {
    type = string
}

variable "availability_zone_us_east_1a" {
    type = string
}

variable "availability_zone_us_east_1b" {
    type = string
}

variable "public_subnet_1" {
    type = string
}

variable "public_subnet_2" {
    type = string
}

variable "private_subnet_1" {
    type = string
}

variable "private_subnet_2" {
    type = string
}