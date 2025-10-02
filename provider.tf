provider "aws" {
  region = var.region

  ignore_tags {
    key_prefixes = ["QSConfigId"]
  }
}
