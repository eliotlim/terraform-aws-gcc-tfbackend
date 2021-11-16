# Backend details
variable "Agency-Code" {
  description = "The agency initials"
  type        = string
}

variable "Project-Code" {
  description = "The project code"
  type        = string
}

variable "Environment" {
  description = "The environment (e.g. tXX, dev, stg, uat, prd)"
  type        = string
}

variable "Zone" {
  description = "The zone (e.g. iz, ez, mz ,dz)"
  type        = string
  default     = null
}

variable "Tier" {
  description = "Tier identifier (e.g. web, gut, app, it, db, svc, na)"
  type        = string
  default     = null
}

# Configuration for Backend Resources
variable "prevent_destroy" {
  description = "Prevent accidental destruction of the Terraform state bucket"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS Region selection"
  type        = string
  default     = "ap-southeast-1"
}

variable "versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

# Configure Terraform Backend in remote mode
variable "bucket" {
  description = "Name of the S3 Bucket"
  type        = string
  default     = ""
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = ""
}

variable "encrypt" {
  description = "Encrypt the contents of the bucket"
  type        = bool
  default     = true
}

variable "key" {
  description = "Key to use for the Terraform state file"
  type        = string
  default     = "terraform.tfstate"
}