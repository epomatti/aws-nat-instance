output "ssm_start_session_nat_instance" {
  value = var.create_nat_instance == true ? "aws ssm start-session --target ${module.nat-instance[0].instance_id} --region ${var.region}" : null

}
output "ssm_start_session_private_server" {
  value = var.create_private_server == true ? "aws ssm start-session --target ${module.server[0].instance_id} --region ${var.region}" : null
}

output "lambda_vpc_executcion_role" {
  value = module.iam_lambda.execution_role_arn
}
