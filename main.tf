terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source   = "./modules/vpc"
  region   = var.region
  workload = var.workload
}

module "nat-instance" {
  source   = "./modules/ec2/nat-instance"
  workload = var.workload
  vpc_id   = module.vpc.vpc_id
  subnet   = module.vpc.subnet_public1_id
}

module "server" {
  count                    = var.create_private_server == true ? 1 : 0
  source                   = "./modules/ec2/server"
  workload                 = var.workload
  vpc_id                   = module.vpc.vpc_id
  subnet                   = module.vpc.subnet_private1_id
  region                   = var.region
  route_table_id           = module.vpc.private_route_table_id
  nat_network_interface_id = module.nat-instance.network_interface_id
}

module "vpc_endpoints" {
  count             = var.create_vpc_endpoints == true ? 1 : 0
  source            = "./modules/endpoints"
  workload          = var.workload
  vpc_id            = module.vpc.vpc_id
  subnet            = module.vpc.subnet_private1_id
  region            = var.region
  security_group_id = module.server.security_group_id
}
