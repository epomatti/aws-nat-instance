variable "region" {
  type    = string
  default = "us-east-2"
}

variable "workload" {
  type    = string
  default = "corp"
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
