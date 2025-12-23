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

module "ssm" {
  source              = "./modules/ssm"
  usg_bucket          = module.s3.usg_bucket
  postgresql_address  = var.create_rds == true ? module.rds.address : "{}"
  postgresql_username = var.rds_username
  postgresql_password = var.rds_password
}

module "nat_instance" {
  count             = var.create_nat_instance == true ? 1 : 0
  source            = "./modules/ec2/nat_instance"
  workload          = var.workload
  vpc_id            = module.vpc.vpc_id
  subnet            = module.vpc.subnet_public1_id
  instance_type     = var.instance_type
  ami               = var.ami
  userdata          = var.userdata
  create_eip        = var.create_eip
  availability_zone = module.vpc.primary_az

  depends_on = [module.ssm]
}

module "cohesive_vns3" {
  count         = var.create_cohesive_nat == true ? 1 : 0
  source        = "./modules/vns3_nate"
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
  private_subnet1_id       = module.vpc.subnet_private1_id
  private_subnet2_id       = module.vpc.subnet_private2_id
  region                   = var.region
  route_table1_id          = module.vpc.private_route_table1_id
  route_table2_id          = module.vpc.private_route_table2_id
  nat_network_interface_id = var.create_nat_gateway ? module.nat_gateway[0].network_interface_id : module.nat_instance[0].network_interface_id
  ami                      = var.ami
  availability_zone        = module.vpc.primary_az
  vpc_cidr_block           = module.vpc.vpc_cidr_block
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
  source = "./modules/vpc_bpa"

  create_nat_subnet_exclusion     = var.create_nat_subnet_exclusion
  create_private_subnet_exclusion = var.create_private_subnet_exclusion

  vpc_internet_gateway_block_mode                    = var.vpc_internet_gateway_block_mode
  vpc_nat_subnet_internet_gateway_exclusion_mode     = var.vpc_nat_subnet_internet_gateway_exclusion_mode
  vpc_private_subnet_internet_gateway_exclusion_mode = var.vpc_private_subnet_internet_gateway_exclusion_mode

  nat_subnet_id     = module.vpc.subnet_public1_id
  private_subnet_id = module.vpc.subnet_private1_id
}

module "nat_gateway" {
  count            = var.create_nat_gateway == true ? 1 : 0
  source           = "./modules/nat_gateway"
  workload         = var.workload
  public_subnet_id = module.vpc.subnet_public1_id
}

module "s3" {
  source = "./modules/s3"
}

module "iam_lambda" {
  source     = "./modules/iam/lambda"
  workload   = var.workload
  aws_region = var.region
}

module "iam_lambda2" {
  source   = "./modules/iam/lambda2"
  workload = var.workload
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

  vpc_cidr_block = module.vpc.vpc_cidr_block
}

module "rds" {
  count                   = var.create_rds ? 1 : 0
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

module "lambda2" {
  source                       = "./modules/lambda2"
  name                         = var.workload
  execution_role_arn           = module.iam_lambda2.execution_role_arn
  lambda_handler_zip           = var.lambda_handler_zip
  lambda_architectures         = var.lambda_architectures
  lambda_runtime               = var.lambda_runtime
  lambda_handler               = var.lambda_handler
  memory_size                  = var.lambda_memory_size
  timeout                      = var.lambda_timeout
  lambda_log_format            = var.lambda_log_format
  lambda_log_group_name        = module.cloudwatch.lambda_name
  lambda_application_log_level = var.lambda_application_log_level
  lambda_system_log_level      = var.lambda_system_log_level
}
