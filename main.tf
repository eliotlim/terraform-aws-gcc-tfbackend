provider "aws" {
  region = var.region
}

locals {
  environment = "${var.tags["Agency-Code"]}-${var.tags["Account-Type"]}-${var.tags["Project-Code"]}"
}

resource "aws_s3_bucket" "state" {
  bucket = "sst-s3-${local.environment}-tfstate"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  versioning {
    enabled = var.versioning
  }

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(var.tags, {
    Name = "sst-s3-${local.environment}-tfstate"
  })
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
