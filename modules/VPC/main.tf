# Create VPC
resource "aws_vpc" "client1_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "client1_vpc"
  }
}