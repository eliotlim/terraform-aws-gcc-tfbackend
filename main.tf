provider "aws" {
  region = var.region
}

module "tags" {
  source = "github.com/eliotlim/terraform-aws-gcc-tags"

  Agency-Code  = var.Agency-Code
  Project-Code = var.Project-Code
  Environment  = var.Environment
  Zone         = var.Zone
  Tier         = var.Tier
}

resource "aws_s3_bucket" "state" {
  bucket = "sst-s3-${var.Agency-Code}-${module.tags.desc}-tfstate"
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

  tags = merge(module.tags.tags, {
    Name = "sst-s3-${var.Agency-Code}-${module.tags.desc}-tfstate"
  })
}

resource "aws_dynamodb_table" "lock" {
  name         = "dbs-dynamodb-${module.tags.desc}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(module.tags.tags, {
    Name = "dbs-dynamodb-${module.tags.desc}-tflock"
  })
}
