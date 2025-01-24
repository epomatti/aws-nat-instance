output "security_group_id" {
  value = aws_security_group.server.id
}

output "instance_id" {
  value = aws_instance.server.id
}
