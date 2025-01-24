variable "vpc_internet_gateway_block_mode" {
  type = string
}

variable "vpc_nat_subnet_internet_gateway_exclusion_mode" {
  type = string
}

variable "vpc_private_subnet_internet_gateway_exclusion_mode" {
  type = string
}

variable "nat_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}
