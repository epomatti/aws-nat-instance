locals {
  config_file = file("${path.module}/config.json")
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
