output "tfstate_dev_bucket" {
  value       = module.terraform_state_bucket.s3_bucket_id
  description = "S3 bucket that holds tfstate for dev modules."
}

output "tfstate_dev_dynamo_table" {
  value       = module.terraform_state_lock_table.dynamodb_table_id
  description = "Dynamo DB lock table for dev tfstate."
}
