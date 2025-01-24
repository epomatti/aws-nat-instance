# General
region = "us-east-2"

# NAT instance
create_nat_instance = true
instance_type       = "t4g.micro"
userdata            = "ubuntu.sh"
ami                 = "ami-0ac5d9e789dbb455a"

# Cohesive VNS3 NATe
create_cohesive_nat    = false
cohesive_instance_type = "t3a.micro"
cohesive_ami           = "ami-02f11042622448b19"

# Server
create_private_server = false
create_vpc_endpoints  = false
