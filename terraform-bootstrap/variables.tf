variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_repo" {
  type        = string
  description = "OWNER/REPO, e.g. Param2ray/ecs-production-healthcheck-service"
}

variable "state_bucket" {
  type        = string
  description = "S3 bucket name storing terraform state"
}

variable "lock_table_arn" {
  type        = string
  description = "ARN of DynamoDB table used for terraform state locking"
}

