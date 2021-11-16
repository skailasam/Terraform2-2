resource "aws_default_vpc" "default-vpc" {
  tags = {
    Name = var.vpc_name
  }
}
