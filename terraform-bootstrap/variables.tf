variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_repo" {
  description = "OWNER/REPO, e.g. Param2ray/ecs-production-healthcheck-service"
  type        = string

  validation {
    condition     = can(regex(".+/.+", var.github_repo))
    error_message = "github_repo must be in OWNER/REPO format (example: Param2ray/ecs-production-healthcheck-service)."
  }
}


variable "state_bucket" {
  type        = string
  description = "S3 bucket name storing terraform state"
}

variable "lock_table_arn" {
  type        = string
  description = "ARN of DynamoDB table used for terraform state locking"
}

