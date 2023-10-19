variable "region" {
  type    = string
  default = "us-east-2"
}

variable "workload" {
  type    = string
  default = "corp"
}

variable "create_private_server" {
  type    = bool
  default = false
}

variable "create_vpc_endpoints" {
  type    = bool
  default = false
}
