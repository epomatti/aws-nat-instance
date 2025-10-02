locals {
  config_file = file("${path.module}/config.json")
  path        = "/litware/lambda"
}

resource "aws_ssm_parameter" "cloudwath_config_file" {
  name  = "AmazonCloudWatch-linux-terraform"
  type  = "String"
  value = local.config_file
}

resource "aws_ssm_parameter" "usg_bucket" {
  name  = "usg-bucket"
  type  = "String"
  value = var.usg_bucket
}

resource "aws_ssm_parameter" "postgresql_address" {
  name  = "${local.path}/postgresql/address"
  type  = "String"
  value = var.postgresql_address
}

resource "aws_ssm_parameter" "postgresql_username" {
  name  = "${local.path}/postgresql/username"
  type  = "String"
  value = var.postgresql_username
}

resource "aws_ssm_parameter" "postgresql_password" {
  name  = "${local.path}/postgresql/password"
  type  = "SecureString"
  value = var.postgresql_password
}
