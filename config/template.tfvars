# General
region = "us-east-2"

# NAT instance
create_nat_instance = true
instance_type       = "t4g.micro"
userdata            = "ubuntu.sh"
ami                 = "ami-0ac5d9e789dbb455a"

# VPC
apply_bpc_bpa = true
# create_nat_subnet_exclusion                        = false
# create_private_subnet_exclusion                        = false
vpc_internet_gateway_block_mode                    = "block-bidirectional" # "block-bidirectional", "block-ingress", "off"
vpc_nat_subnet_internet_gateway_exclusion_mode     = "allow-bidirectional" # "allow-bidirectional", "allow-egress"
vpc_private_subnet_internet_gateway_exclusion_mode = "allow-egress"        # "allow-bidirectional", "allow-egress"

# Cohesive VNS3 NATe
create_cohesive_nat    = false
cohesive_instance_type = "t3a.micro"
cohesive_ami           = "ami-02f11042622448b19"

# Server
create_private_server = true
create_vpc_endpoints  = false
