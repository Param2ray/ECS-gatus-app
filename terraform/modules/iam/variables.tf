variable "enable_destroy_policy" {
  description = "Whether to create/attach the GitHub Actions runtime destroy policy"
  type        = bool
  default     = false
}

variable "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role (OIDC)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in OWNER/REPO format, used in OIDC trust policy"
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}


