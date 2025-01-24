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
