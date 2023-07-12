terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  az1 = "${var.region}a"
}

module "network" {
  source   = "./modules/network"
  region   = var.region
  workload = var.workload
  az       = local.az1
}

module "nat-instance" {
  source   = "./modules/nat-instance"
  workload = var.workload
  vpc_id   = module.network.vpc_id
  subnet   = module.network.subnet_public1_id
  az       = local.az1
}

module "server" {
  source   = "./modules/server"
  workload = var.workload
  vpc_id   = module.network.vpc_id
  subnet   = module.network.subnet_private1_id
  az       = local.az1
  region   = var.region
}
