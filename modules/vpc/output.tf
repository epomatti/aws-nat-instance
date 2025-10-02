output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "primary_az" {
  value = local.az1
}

output "subnet_private1_id" {
  value = aws_subnet.private1.id
}

output "subnet_private2_id" {
  value = aws_subnet.private2.id
}

output "subnet_public1_id" {
  value = aws_subnet.public1.id
}

output "vpc_endpoints_subnet_id" {
  value = aws_subnet.vpc_endpoints.id
}

output "private_route_table1_id" {
  value = aws_route_table.private1.id
}

output "private_route_table2_id" {
  value = aws_route_table.private2.id
}
