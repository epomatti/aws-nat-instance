output "postgresql_address_arn" {
  value = aws_ssm_parameter.postgresql_address.arn
}

output "postgresql_address_name" {
  value = aws_ssm_parameter.postgresql_address.name
}

output "postgresql_username_arn" {
  value = aws_ssm_parameter.postgresql_username.arn
}

output "postgresql_username_name" {
  value = aws_ssm_parameter.postgresql_username.name
}

output "postgresql_password_arn" {
  value = aws_ssm_parameter.postgresql_password.arn
}

output "postgresql_password_name" {
  value = aws_ssm_parameter.postgresql_password.name
}
