terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
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
  count         = var.create_nat_instance == true ? 1 : 0
  source        = "./modules/ec2/nat-instance"
  workload      = var.workload
  vpc_id        = module.vpc.vpc_id
  subnet        = module.vpc.subnet_public1_id
  instance_type = var.instance_type
  ami           = var.ami
  userdata      = var.userdata
}

module "cohesive_vns3" {
  count         = var.create_cohesive_nat == true ? 1 : 0
  source        = "./modules/vns3-nate"
  workload      = var.workload
  vpc_id        = module.vpc.vpc_id
  subnet        = module.vpc.subnet_public1_id
  instance_type = var.cohesive_instance_type
  ami           = var.cohesive_ami
}

module "server" {
  count                    = var.create_private_server == true ? 1 : 0
  source                   = "./modules/ec2/server"
  workload                 = var.workload
  vpc_id                   = module.vpc.vpc_id
  subnet                   = module.vpc.subnet_private1_id
  region                   = var.region
  route_table_id           = module.vpc.private_route_table_id
  nat_network_interface_id = module.nat-instance[0].network_interface_id
  ami                      = var.ami
}

module "vpc_endpoints" {
  count      = var.create_vpc_endpoints == true ? 1 : 0
  source     = "./modules/endpoints"
  workload   = var.workload
  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.subnet_private1_id, module.vpc.subnet_public1_id]
  region     = var.region
}

module "vpc_block_public_access" {
  count  = var.apply_bpc_bpa == true ? 1 : 0
  source = "./modules/vpc-bpa"

  vpc_internet_gateway_block_mode                    = var.vpc_internet_gateway_block_mode
  vpc_nat_subnet_internet_gateway_exclusion_mode     = var.vpc_nat_subnet_internet_gateway_exclusion_mode
  vpc_private_subnet_internet_gateway_exclusion_mode = var.vpc_private_subnet_internet_gateway_exclusion_mode

  nat_subnet_id     = module.vpc.subnet_public1_id
  private_subnet_id = module.vpc.subnet_private1_id
}
