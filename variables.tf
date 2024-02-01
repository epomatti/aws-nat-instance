variable "region" {
  type = string
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
