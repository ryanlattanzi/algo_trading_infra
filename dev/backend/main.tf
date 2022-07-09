terraform {
  backend "s3" {
    # S3 to store backend infra
    bucket = "terraform-state-dev-596964673232"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    # Dynamo table for locking
    dynamodb_table = "terraform-state-dev-lock-table"
    encrypt        = true
  }
}

module "terraform_state_bucket" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = "3.3.0"
  bucket                  = "terraform-state-dev-596964673232"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  versioning = {
    status = "Enabled"
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = module.terraform_state_bucket.s3_bucket_id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

module "terraform_state_lock_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  version  = "2.0.0"
  name     = "terraform-state-dev-lock-table"
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}
