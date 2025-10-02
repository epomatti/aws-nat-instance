locals {
  filename = "${path.module}/handlers/${var.lambda_handler_zip}"
}

resource "aws_lambda_function_url" "auth_none" {
  function_name      = aws_lambda_function.lambda2.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_function" "lambda2" {
  function_name                      = "${var.name}2"
  description                        = "Lambda to test VPC NAT egress"
  role                               = var.execution_role_arn
  filename                           = local.filename
  source_code_hash                   = filebase64sha256(local.filename)
  architectures                      = var.lambda_architectures
  runtime                            = var.lambda_runtime
  handler                            = var.lambda_handler
  replace_security_groups_on_destroy = true

  memory_size = var.memory_size
  timeout     = var.timeout


  logging_config {
    log_format            = var.lambda_log_format
    log_group             = var.lambda_log_group_name
    application_log_level = var.lambda_application_log_level
    system_log_level      = var.lambda_system_log_level
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }
}
