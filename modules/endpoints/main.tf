### VPC Endpoints for Session Manager ###

# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
# https://repost.aws/knowledge-center/ec2-systems-manager-vpc-endpoints

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  auto_accept       = true

  subnet_ids = [var.subnet]

  ip_address_type = "ipv4"

  security_group_ids = [
    var.security_group_id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  auto_accept       = true

  subnet_ids = [var.subnet]

  ip_address_type = "ipv4"

  security_group_ids = [
    var.security_group_id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  auto_accept       = true

  subnet_ids = [var.subnet]

  ip_address_type = "ipv4"

  security_group_ids = [
    var.security_group_id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  auto_accept       = true

  subnet_ids = [var.subnet]

  ip_address_type = "ipv4"

  security_group_ids = [
    var.security_group_id,
  ]

  private_dns_enabled = true
}
