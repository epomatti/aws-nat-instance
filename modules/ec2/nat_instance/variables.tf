variable "workload" {
  type = string
}

variable "subnet" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "userdata" {
  type = string
}

variable "create_eip" {
  type = bool
}

variable "availability_zone" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}
