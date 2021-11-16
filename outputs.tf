output "bucket" {
  description = "Name of the S3 Bucket"
  value       = aws_s3_bucket.state.bucket
}

output "dynamodb_table" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.lock.name
}

output "encrypt" {
  description = "Encrypt the contents of the bucket"
  value       = var.encrypt
}

output "key" {
  description = "Key to use for the Terraform state file"
  value       = var.key
}

output "region" {
  description = "AWS Region selection"
  value       = var.region
}
