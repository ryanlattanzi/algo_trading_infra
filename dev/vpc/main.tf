terraform {
  backend "s3" {
    # S3 to store backend infra
    bucket = "terraform-state-dev-596964673232"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"

    # Dynamo table for locking
    dynamodb_table = "terraform-state-dev-lock-table"
    encrypt        = true
  }
}

locals {
  tags = {
    Environment = "dev"
  }
}


module "postgres_price_db_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "price-db-vpc"
  cidr = "10.0.0.0/24"

  azs              = ["us-east-1a", "us-east-1b"]
  public_subnets   = ["10.0.0.0/28", "10.0.0.16/28"]
  private_subnets  = ["10.0.0.128/28", "10.0.0.144/28"]
  database_subnets = ["10.0.0.192/28", "10.0.0.208/28"]

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  tags = local.tags
}

module "postgres_price_db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "price-db-sg"
  description = "Security group for price database instance access."
  vpc_id      = module.postgres_price_db_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Price database access from within VPC"
      cidr_blocks = module.postgres_price_db_vpc.vpc_cidr_block
    }
  ]

  tags = local.tags
}
