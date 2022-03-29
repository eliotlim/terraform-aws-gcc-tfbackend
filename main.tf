provider "aws" {
  region = var.region
}

locals {
  environment = "${var.tags["Agency-Code"]}-${var.tags["Account-Type"]}-${var.tags["Project-Code"]}"
}

resource "aws_s3_bucket" "state" {
  bucket = "sst-s3-${local.environment}-tfstate"

  force_destroy = var.prevent_destroy == false

  tags = merge(var.tags, {
    Name = "sst-s3-${local.environment}-tfstate"
  })
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.state.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = "dbs-dynamodb-${local.environment}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = "dbs-dynamodb-${local.environment}-tflock"
  })
}
