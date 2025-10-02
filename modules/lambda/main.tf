locals {
  filename = "${path.module}/handlers/${var.lambda_handler_zip}"
}

resource "aws_lambda_function_url" "auth_none" {
  function_name      = aws_lambda_function.sqs.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_function" "sqs" {
  function_name                      = var.name
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

  environment {
    variables = {
      SSM_POSTGRESQL_ADDRESS  = var.ssm_postgresql_address
      SSM_POSTGRESQL_USERNAME = var.ssm_postgresql_username
      SSM_POSTGRESQL_PASSWORD = var.ssm_postgresql_password
    }
  }

  logging_config {
    log_format            = var.lambda_log_format
    log_group             = var.lambda_log_group_name
    application_log_level = var.lambda_application_log_level
    system_log_level      = var.lambda_system_log_level
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      vpc_config,
    ]
  }
}

resource "aws_security_group" "lambda" {
  name        = "lambda-vpc"
  description = "Allow TLS outbound Lambda traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-lambda-vpc"
  }
}

resource "aws_security_group_rule" "egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group_rule" "egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}

resource "aws_security_group_rule" "egress_postgresql" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.lambda.id
}

