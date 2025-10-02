output "db_identifier" {
  value = aws_db_instance.default.identifier
}

output "db_name" {
  value = aws_db_instance.default.db_name
}

output "address" {
  value = aws_db_instance.default.address
}

output "rds_resource_id" {
  value = aws_db_instance.default.resource_id
}
