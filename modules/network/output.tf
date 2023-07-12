output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_private1_id" {
  value = aws_subnet.private1.id
}

output "subnet_public1_id" {
  value = aws_subnet.public1.id
}
