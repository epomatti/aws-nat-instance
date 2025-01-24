resource "aws_eip" "default" {
  domain = "vpc"
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.default.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "nat-${var.workload}"
  }
}
