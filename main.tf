# ------------------------------------------------------------------------------
# DB SUBNET GROUP
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  subnet_ids = var.db_subnet_ids
}

# ------------------------------------------------------------------------------
# RANDOM PASSWORD
# ------------------------------------------------------------------------------

resource "random_password" "this" {
  length  = var.password_length
  special = false
}

# ------------------------------------------------------------------------------
# SECRET MANAGER
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "this" {
  name        = "${terraform.workspace}/rds/${var.db_name}"
  description = "${terraform.workspace} - ${var.db_name} RDS secrets"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    "DATABASE_PASSWORD" : "${random_password.this.result}"
    "DATABASE_USER" : "${var.username}"
  })
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  vpc_id      = data.aws_db_subnet_group.this.vpc_id
  name_prefix = "${terraform.workspace}-rds-${var.db_name}"

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# RDS
# ------------------------------------------------------------------------------

# We could add a DB parameter group if the instance requires a special config.
# resource "aws_db_parameter_group" "this" {
# }

# Will add more feature flags
resource "aws_db_instance" "this" {
  apply_immediately                   = var.apply_immediately
  allocated_storage                   = var.allocated_storage
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  storage_type                        = "gp2"
  db_name                             = var.db_name
  password                            = random_password.this.result
  username                            = var.username
  backup_retention_period             = 7
  backup_window                       = var.backup_window
  maintenance_window                  = var.maintenance_window
  auto_minor_version_upgrade          = true
  skip_final_snapshot                 = var.skip_final_snapshot
  multi_az                            = var.multi_az
  db_subnet_group_name                = data.aws_db_subnet_group.this.name
  publicly_accessible                 = false
  storage_encrypted                   = var.storage_encrypted
  deletion_protection                 = var.deletion_protection
  vpc_security_group_ids              = [aws_security_group.this.id]

  tags = {
    Classification = var.data_classification_tag
    DatabaseName   = var.db_name
  }
}