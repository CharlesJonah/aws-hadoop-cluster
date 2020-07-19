# INSTANCES #
resource "aws_instance" "ec2" {
  count                  = var.instance_count
  ami                    = var.aws_ami
  associate_public_ip_address = var.associate_public_ip_address
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  tags                   = var.common_tags
}