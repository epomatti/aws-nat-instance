### VPC Endpoints for Session Manager ###

# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
# https://repost.aws/knowledge-center/ec2-systems-manager-vpc-endpoints

locals {
  service_name_prefix = "com.amazonaws.${var.region}."
  services = [
    "ssm",
    "ec2messages",
    "ec2",
    "ssmmessages"
  ]
}

resource "aws_vpc_endpoint" "endpoints_nat_subnet" {
  for_each          = toset(local.services)
  vpc_id            = var.vpc_id
  service_name      = "${local.service_name_prefix}${each.key}"
  vpc_endpoint_type = "Interface"
  auto_accept       = true

  subnet_ids = [var.vpc_endpoints_subnet_id]

  ip_address_type = "ipv4"

  security_group_ids = [
    aws_security_group.default.id
  ]

  private_dns_enabled = true
}

# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.${var.region}.ssm"
#   vpc_endpoint_type = "Interface"
#   auto_accept       = true

#   subnet_ids = var.subnet_ids

#   ip_address_type = "ipv4"

#   security_group_ids = [
#     aws_security_group.default.id
#   ]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.${var.region}.ec2messages"
#   vpc_endpoint_type = "Interface"
#   auto_accept       = true

#   subnet_ids = var.subnet_ids

#   ip_address_type = "ipv4"

#   security_group_ids = [
#     aws_security_group.default.id
#   ]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ec2" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.${var.region}.ec2"
#   vpc_endpoint_type = "Interface"
#   auto_accept       = true

#   subnet_ids = var.subnet_ids

#   ip_address_type = "ipv4"

#   security_group_ids = [
#     aws_security_group.default.id
#   ]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.${var.region}.ssmmessages"
#   vpc_endpoint_type = "Interface"
#   auto_accept       = true

#   subnet_ids = var.subnet_ids

#   ip_address_type = "ipv4"

#   security_group_ids = [
#     aws_security_group.default.id
#   ]

#   private_dns_enabled = true
# }

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "default" {
  name        = "vpc-endpoint-${var.workload}"
  description = "VPC Endpoints Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-vpc-endpoint-${var.workload}"
  }
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "ingress_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.default.id
}
