locals {
  name = "cohesive"
}

resource "aws_eip" "default" {
  domain = "vpc"

  tags = {
    Name = "vns3-elastic-ip"
  }
}

resource "aws_key_pair" "vns3" {
  key_name   = "vns3-key"
  public_key = file("${path.module}/../../keys/vns3.pub")
}

resource "aws_iam_instance_profile" "nat_instance" {
  name = "${var.workload}-${local.name}"
  role = aws_iam_role.nat_instance.id
}

resource "aws_instance" "nat_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  associate_public_ip_address = true
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.nat_instance.id]

  iam_instance_profile = aws_iam_instance_profile.nat_instance.id
  key_name             = aws_key_pair.vns3.key_name

  # Requirement for NAT
  source_dest_check = false

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
    Name = "${var.workload}-${local.name}"
  }
}

### IAM Role ###
resource "aws_iam_role" "nat_instance" {
  name = "${var.workload}-${local.name}"

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

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.nat_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "nat_instance" {
  name        = "ec2-ssm-${var.workload}-${local.name}"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-ssm-${var.workload}-${local.name}"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.nat_instance.id
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.nat_instance.id
}

resource "aws_security_group_rule" "cohesive_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_instance.id
}

resource "aws_security_group_rule" "cohesive_webui" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_instance.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_instance.id
}

# resource "aws_security_group_rule" "egress_http" {
#   type              = "egress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "TCP"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.nat_instance.id
# }

# resource "aws_security_group_rule" "egress_https" {
#   type              = "egress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "TCP"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.nat_instance.id
# }
