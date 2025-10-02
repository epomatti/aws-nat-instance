# General
region = "us-east-2"

# NAT instance
create_nat_instance = true
create_eip          = true
instance_type       = "t4g.micro"
userdata            = "ubuntu.sh"
ami                 = "ami-03d9fcc39480315d4"

# VPC
apply_vpc_bpa                                      = false
create_nat_subnet_exclusion                        = true
create_private_subnet_exclusion                    = true
vpc_internet_gateway_block_mode                    = "block-bidirectional" # "block-bidirectional", "block-ingress", "off"
vpc_nat_subnet_internet_gateway_exclusion_mode     = "allow-bidirectional" # "allow-bidirectional", "allow-egress"
vpc_private_subnet_internet_gateway_exclusion_mode = "allow-bidirectional" # "allow-bidirectional", "allow-egress"

# Cohesive VNS3 NATe
create_cohesive_nat    = false
cohesive_instance_type = "t3a.micro"
cohesive_ami           = "ami-02f11042622448b19"

# Server
create_private_server = false
create_vpc_endpoints  = false

# NAT Gateway
# This will change the routing of the provider server to use the NAT Gateway
create_nat_gateway = false

### Lambda ###
lambda_memory_size   = 1024
lambda_timeout       = 30
lambda_architectures = ["arm64"]
lambda_handler_zip   = "python/lambda-python.zip"
lambda_runtime       = "python3.13"
lambda_handler       = "app.lambda_handler"

# Logging
lambda_log_format            = "JSON"
lambda_application_log_level = "INFO"
lambda_system_log_level      = "INFO"

### RDS ###
rds_engine              = "postgres"
rds_engine_version      = "17"
rds_instance_class      = "db.t4g.micro"
rds_publicly_accessible = false
rds_port                = 5432
rds_username            = "dbadmin"
rds_password            = "p4ssw0rd"
