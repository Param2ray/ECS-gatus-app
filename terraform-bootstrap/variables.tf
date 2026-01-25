variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository (owner/name)"
  type        = string
}

variable "state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_arn" {
  description = "DynamoDB lock table ARN"
  type        = string
}
