# General
region = "us-east-2"

# NAT instance
create_nat_instance = false
instance_type       = "t4g.nano"
userdata            = "debian.sh"
ami                 = "ami-0c758b376a9cf7862"

# Cohesive VNS3 NATe
create_cohesive_nat    = false
cohesive_instance_type = "t3a.micro"
cohesive_ami           = "ami-02f11042622448b19"

# Server
create_private_server = false
create_vpc_endpoints  = false
