variable "usg_bucket" {
  type = string
}

variable "postgresql_address" {
  type = string
}

variable "postgresql_username" {
  type = string
}

variable "postgresql_password" {
  type      = string
  sensitive = true
}
