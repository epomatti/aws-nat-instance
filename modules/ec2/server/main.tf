resource "aws_iam_instance_profile" "main" {
  name = "${var.workload}-server"
  role = aws_iam_role.server.id
}

resource "aws_instance" "server" {
  ami           = var.ami
  instance_type = "t4g.nano"

  associate_public_ip_address = false
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.server.id]

  iam_instance_profile = aws_iam_instance_profile.main.id
  user_data            = file("${path.module}/userdata/ubuntu.sh")

  # Enables metadata V2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring    = true
  ebs_optimized = true

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
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

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "server" {
  name        = "ec2-ssm-${var.workload}-server"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-ssm-${var.workload}-server"
  }
}

resource "aws_security_group_rule" "egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server.id
}

resource "aws_security_group_rule" "egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server.id
}

### ICMP ###
resource "aws_security_group_rule" "ingress_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.server.id
}

resource "aws_security_group_rule" "egress_icmp" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server.id
}
