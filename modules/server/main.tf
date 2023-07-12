resource "aws_iam_instance_profile" "main" {
  name = "${var.workload}-server"
  role = aws_iam_role.server.id
}

resource "aws_instance" "server" {
  ami           = "ami-08fdd91d87f63bb09"
  instance_type = "t4g.nano"

  associate_public_ip_address = true
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.server.id]

  availability_zone    = var.az
  iam_instance_profile = aws_iam_instance_profile.main.id
  user_data            = file("${path.module}/userdata.sh")

  # Enables metadata V2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring    = false
  ebs_optimized = false

  root_block_device {
    encrypted = true
  }

  lifecycle {
    ignore_changes = [
      ami,
      associate_public_ip_address
    ]
  }

  tags = {
    Name = "${var.workload}-server"
  }
}

### Route to NAT Instance ###
resource "aws_route" "nat" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.nat_network_interface_id
}

### IAM Role ###

resource "aws_iam_role" "server" {
  name = "server-${var.workload}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.server.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_security_group" "server" {
  name        = "ec2-sessionmanager-server"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-sessionmanager-server"
  }
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.server.id
}

resource "aws_security_group_rule" "egress_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.server.id
}

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
    aws_security_group.server.id,
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
    aws_security_group.server.id,
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
    aws_security_group.server.id,
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
    aws_security_group.server.id,
  ]

  private_dns_enabled = true
}

# resource "aws_security_group" "allow_public_subnet" {
#   name        = "rds-pe-${var.workload}"
#   description = "Allow TLS inbound traffic to RDS Postgres"
#   vpc_id      = var.vpc_id

#   tags = {
#     Name = "sg-rds-pe-${var.workload}"
#   }
# }

# resource "aws_security_group_rule" "ingress_from_public_subnet" {
#   description       = "Allows connection public subnet"
#   type              = "ingress"
#   from_port         = 5432
#   to_port           = 5432
#   protocol          = "tcp"
#   cidr_blocks       = [var.vpc_cidr_block]
#   ipv6_cidr_blocks  = []
#   security_group_id = aws_security_group.allow_public_subnet.id
# }

# resource "aws_security_group_rule" "egress_from_pe_to_rds" {
#   description       = "Allows connection from the private endpoint to the RDS"
#   type              = "egress"
#   from_port         = 5432
#   to_port           = 5432
#   protocol          = "tcp"
#   cidr_blocks       = [var.vpc_cidr_block]
#   ipv6_cidr_blocks  = []
#   security_group_id = aws_security_group.allow_public_subnet.id
# }
