# Project
region = "us-east-2"

# NAT instance
instance_type = "t4g.nano"
userdata      = "debian.sh"
ami           = "ami-0c758b376a9cf7862"

# Server
create_private_server = true
create_vpc_endpoints  = false
