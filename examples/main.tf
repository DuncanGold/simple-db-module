terraform {
  backend "s3" {
    profile = "deployment"
  }
}

provider "aws" {
  profile = terraform.workspace
  region  = "eu-west-3"

  default_tags {
    tags = {
      Environment = terraform.workspace
      ManagedBy   = "terraform"
      Ownership   = "devops@duncan.com"
      Repository  = "infra/modules/simple-database"
    }
  }
}

# ------------------------------------------------------------------------------
# VPC (DATA)
# ------------------------------------------------------------------------------

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}

# ------------------------------------------------------------------------------
# SUBNETS (DATA)
# ------------------------------------------------------------------------------

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

# ------------------------------------------------------------------------------
# SECURITY GROUP RULE
# ------------------------------------------------------------------------------

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["10.30.2.32/32"] # Allow my company VPN's range for example
  protocol          = "tcp"
  security_group_id = module.rds.security_group.id
}

# ------------------------------------------------------------------------------
# RDS MODULE
# ------------------------------------------------------------------------------

module "rds" {
  source = "../../simple-db-module"

  allocated_storage         = 20
  db_name                   = "my_db"
  engine                    = "postgres"
  engine_version            = "13.4"
  db_parameter_group_family = "postgres13"
  db_subnet_ids             = data.aws_subnets.this.ids
}