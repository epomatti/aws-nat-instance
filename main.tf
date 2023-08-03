terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
  source                   = "./modules/server"
  workload                 = var.workload
  vpc_id                   = module.network.vpc_id
  subnet                   = module.network.subnet_private1_id
  az                       = local.az1
  region                   = var.region
  route_table_id           = module.network.private_route_table_id
  nat_network_interface_id = module.nat-instance.network_interface_id
}
