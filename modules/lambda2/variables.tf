variable "name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "lambda_handler_zip" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_architectures" {
  type = list(string)
}

variable "lambda_runtime" {
  type = string
}

variable "memory_size" {
  type = number
}

variable "timeout" {
  type = number
}

variable "lambda_log_format" {
  type = string
}

variable "lambda_log_group_name" {
  type = string
}

variable "lambda_application_log_level" {
  type = string
}

variable "lambda_system_log_level" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ssm_postgresql_address" {
  type = string
}

variable "ssm_postgresql_username" {
  type = string
}

variable "ssm_postgresql_password" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}
