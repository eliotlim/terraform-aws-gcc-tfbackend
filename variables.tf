# Backend details
variable "tags" {
  description = "Resource tags describing: { Account-Type, Agency-Code, Project-Code, Environment }"
  type        = map(string)

  validation {
    condition     = can(lookup(var.tags, "Account-Type"))
    error_message = "The Account-Type tag should be specified (e.g. prod, sdlc)."
  }

  validation {
    condition     = can(lookup(var.tags, "Agency-Code"))
    error_message = "The Agency-Code tag should be specified (e.g. abcd)."
  }

  validation {
    condition     = can(lookup(var.tags, "Project-Code"))
    error_message = "The Project-Code tag should be specified (e.g. demo, abc3)."
  }
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
