## VPC Block ###
resource "aws_vpc_block_public_access_options" "default" {
  internet_gateway_block_mode = var.vpc_internet_gateway_block_mode
}

resource "aws_vpc_block_public_access_exclusion" "nat_subnet" {
  subnet_id                       = var.nat_subnet_id
  internet_gateway_exclusion_mode = var.vpc_nat_subnet_internet_gateway_exclusion_mode

  tags = {
    Name = "nat-subnet"
  }
}

resource "aws_vpc_block_public_access_exclusion" "private_subnet" {
  subnet_id                       = var.private_subnet_id
  internet_gateway_exclusion_mode = var.vpc_private_subnet_internet_gateway_exclusion_mode

  tags = {
    Name = "private-subnet"
  }
}
