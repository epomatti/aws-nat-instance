variable "vpc_id" {
  type = string
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "rds_engine" {
  type = string
}

variable "rds_engine_version" {
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

variable "rds_publicly_accessible" {
  type = bool
}

variable "availability_zone" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}
