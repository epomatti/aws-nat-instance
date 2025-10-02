locals {
  name = "litware"
}

resource "aws_db_instance" "default" {
  identifier = "pg-${local.name}-database-1"

  db_name        = "appdb"
  engine         = var.rds_engine
  engine_version = var.rds_engine_version

  username = var.rds_username
  password = var.rds_password

  iam_database_authentication_enabled = false

  availability_zone = var.availability_zone

  publicly_accessible = var.rds_publicly_accessible
  instance_class      = var.rds_instance_class
  port                = var.rds_port
  allocated_storage   = 20
  storage_type        = "gp3"
  storage_encrypted   = true
  multi_az            = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false

  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  performance_insights_enabled = false

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]

  blue_green_update {
    enabled = false
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "rds-group-${local.name}"
  subnet_ids = var.public_subnets_ids
}

### Security Groups ###
resource "aws_security_group" "default" {
  name   = "rds-${local.name}"
  vpc_id = var.vpc_id

  tags = {
    Name = "sg-rds-${local.name}"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.rds_port
  to_port           = var.rds_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.default.id
}
