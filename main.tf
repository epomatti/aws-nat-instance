terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

module "vpc" {
  source   = "./modules/vpc"
  region   = var.region
  workload = var.workload
}

module "nat-instance" {
  count             = var.create_nat_instance == true ? 1 : 0
  source            = "./modules/ec2/nat-instance"
  workload          = var.workload
  vpc_id            = module.vpc.vpc_id
  subnet            = module.vpc.subnet_public1_id
  instance_type     = var.instance_type
  ami               = var.ami
  userdata          = var.userdata
  create_eip        = var.create_eip
  availability_zone = module.vpc.primary_az
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
  nat_network_interface_id = var.create_nat_gateway ? module.nat-gateway[0].network_interface_id : module.nat-instance[0].network_interface_id
  ami                      = var.ami
  availability_zone        = module.vpc.primary_az
}

module "vpc_endpoints" {
  count                   = var.create_vpc_endpoints == true ? 1 : 0
  source                  = "./modules/endpoints"
  workload                = var.workload
  region                  = var.region
  vpc_id                  = module.vpc.vpc_id
  vpc_endpoints_subnet_id = module.vpc.vpc_endpoints_subnet_id
}

module "vpc_block_public_access" {
  count  = var.apply_vpc_bpa == true ? 1 : 0
  source = "./modules/vpc-bpa"

  create_nat_subnet_exclusion     = var.create_nat_subnet_exclusion
  create_private_subnet_exclusion = var.create_private_subnet_exclusion

  vpc_internet_gateway_block_mode                    = var.vpc_internet_gateway_block_mode
  vpc_nat_subnet_internet_gateway_exclusion_mode     = var.vpc_nat_subnet_internet_gateway_exclusion_mode
  vpc_private_subnet_internet_gateway_exclusion_mode = var.vpc_private_subnet_internet_gateway_exclusion_mode

  nat_subnet_id     = module.vpc.subnet_public1_id
  private_subnet_id = module.vpc.subnet_private1_id
}

module "nat-gateway" {
  count            = var.create_nat_gateway == true ? 1 : 0
  source           = "./modules/nat-gateway"
  workload         = var.workload
  public_subnet_id = module.vpc.subnet_public1_id
}

module "s3" {
  source = "./modules/s3"
}

module "ssm" {
  source              = "./modules/ssm"
  usg_bucket          = module.s3.usg_bucket
  postgresql_address  = module.rds.address
  postgresql_username = var.rds_username
  postgresql_password = var.rds_password
}

module "iam_lambda" {
  source     = "./modules/iam/lambda"
  workload   = var.workload
  aws_region = var.region
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "lambda" {
  source                       = "./modules/lambda"
  name                         = var.workload
  execution_role_arn           = module.iam_lambda.execution_role_arn
  lambda_handler_zip           = var.lambda_handler_zip
  lambda_architectures         = var.lambda_architectures
  lambda_runtime               = var.lambda_runtime
  lambda_handler               = var.lambda_handler
  memory_size                  = var.lambda_memory_size
  timeout                      = var.lambda_timeout
  vpc_id                       = module.vpc.vpc_id
  lambda_log_format            = var.lambda_log_format
  lambda_log_group_name        = module.cloudwatch.lambda_name
  lambda_application_log_level = var.lambda_application_log_level
  lambda_system_log_level      = var.lambda_system_log_level

  ssm_postgresql_address  = module.ssm.postgresql_address_name
  ssm_postgresql_username = module.ssm.postgresql_username_name
  ssm_postgresql_password = module.ssm.postgresql_password_name
}

module "rds" {
  source                  = "./modules/rds"
  vpc_id                  = module.vpc.vpc_id
  public_subnets_ids      = [module.vpc.subnet_private1_id, module.vpc.subnet_private2_id]
  rds_engine              = var.rds_engine
  rds_engine_version      = var.rds_engine_version
  rds_instance_class      = var.rds_instance_class
  rds_publicly_accessible = var.rds_publicly_accessible
  rds_port                = var.rds_port
  rds_username            = var.rds_username
  rds_password            = var.rds_password
  availability_zone       = module.vpc.primary_az
  vpc_cidr_block          = module.vpc.vpc_cidr_block
}
