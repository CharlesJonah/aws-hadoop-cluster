#PROVIDERS
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "bastion_server_subnet" {
  cidr_block = var.public_subnets[terraform.workspace][0]
}

data "aws_subnet" "master_node_subnet" {
  cidr_block = var.public_subnets[terraform.workspace][0]
}

data "aws_subnet" "worker_node_subnet" {
  cidr_block = var.private_subnets[terraform.workspace][0]
}

resource "aws_key_pair" "aws-terraform-key" {
  key_name = var.key_name
  public_key = file(var.public_key_path)
}

module "aws-hadoop-cluster-vpc" {
  source = "./infrastructure/networking/vpc"
  cidr = var.cidr[terraform.workspace]
  common_tags = local.common_tags
  private_subnet_1 = var.private_subnets[terraform.workspace][0]
  private_subnet_2 = var.private_subnets[terraform.workspace][1]
  public_subnet_1 = var.public_subnets[terraform.workspace][0]
  public_subnet_2 = var.public_subnets[terraform.workspace][1]
  availability_zone_us_east_1a = var.availability_zones[terraform.workspace][0]
  availability_zone_us_east_1b = var.availability_zones[terraform.workspace][1]
}

module "bastion_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion_server_sg_${terraform.workspace}"
  description = "Security group for bastion server"
  vpc_id      = module.aws-hadoop-cluster-vpc.aws-hadoop-cluster-vpc.id
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.bastion_ingress_cidr[0]
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.bastion_ingress_cidr[1]
    },
  ]
}

module "master_node_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "master_node_sg_${terraform.workspace}"
  description = "Security group for master node"
  vpc_id      = module.aws-hadoop-cluster-vpc.aws-hadoop-cluster-vpc.id
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.cidr[terraform.workspace]
    },
  ]
}

module "worker_node_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "worker_node_sg_${terraform.workspace}"
  description = "Security group for worker node"
  vpc_id      = module.aws-hadoop-cluster-vpc.aws-hadoop-cluster-vpc.id
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.cidr[terraform.workspace]
    },
  ]
}

module "aws-hadoop-cluster-vpc-bastion-server" {
  source = "./infrastructure/compute/ec2"
  key_name = var.key_name
  instance_count = 1
  associate_public_ip_address = true
  subnet_id = data.aws_subnet.bastion_server_subnet.id
  security_group_ids = [module.bastion_server_sg.this_security_group_id]
  aws_ami = data.aws_ami.aws-linux.id
  common_tags = local.common_tags
}

module "aws-hadoop-cluster-vpc-master-node" {
  source = "./infrastructure/compute/ec2"
  key_name = var.key_name
  instance_count = 1
  associate_public_ip_address = false
  subnet_id = data.aws_subnet.master_node_subnet.id
  security_group_ids = [module.master_node_sg.this_security_group_id]
  aws_ami = data.aws_ami.aws-linux.id
  common_tags = local.common_tags
}

module "aws-hadoop-cluster-vpc-worker-node" {
  source = "./infrastructure/compute/ec2"
  key_name = var.key_name
  instance_count = 3
  associate_public_ip_address = false
  subnet_id = data.aws_subnet.worker_node_subnet.id
  security_group_ids = [module.worker_node_sg.this_security_group_id]
  aws_ami = data.aws_ami.aws-linux.id
  common_tags = local.common_tags
}