variable "region" {
  type = string
}

variable "workload" {
  type    = string
  default = "corp"
}

### NAT Instance ###
variable "create_nat_instance" {
  type = bool
}

variable "create_eip" {
  type = bool
}

variable "instance_type" {
  type = string
}

variable "userdata" {
  type = string
}

variable "ami" {
  type = string
}

variable "create_private_server" {
  type    = bool
  default = true
}

variable "create_vpc_endpoints" {
  type    = bool
  default = false
}

variable "vpc_internet_gateway_block_mode" {
  type = string
}

variable "vpc_nat_subnet_internet_gateway_exclusion_mode" {
  type = string
}

variable "vpc_private_subnet_internet_gateway_exclusion_mode" {
  type = string
}

### Cohesive ###
variable "create_cohesive_nat" {
  type = bool
}

variable "cohesive_instance_type" {
  type = string
}

variable "cohesive_ami" {
  type = string
}

### Block Public Access ###
variable "apply_vpc_bpa" {
  type = bool
}
variable "create_nat_subnet_exclusion" {
  type = bool
}
variable "create_private_subnet_exclusion" {
  type = bool
}

### NAT Gateway ###
variable "create_nat_gateway" {
  type = bool
}

### Lambda ###
variable "lambda_handler_zip" {
  type = string
}

variable "lambda_memory_size" {
  type = number
}

variable "lambda_timeout" {
  type = number
}

variable "lambda_architectures" {
  type = list(string)
}

variable "lambda_runtime" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_log_format" {
  type = string
}

variable "lambda_application_log_level" {
  type = string
}

variable "lambda_system_log_level" {
  type = string
}


### RDS ###
variable "rds_engine" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_port" {
  type = number
}

variable "rds_username" {
  type      = string
  sensitive = true
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_engine_version" {
  type = string
}

variable "rds_publicly_accessible" {
  type = bool
}
