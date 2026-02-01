variable "enable_destroy_policy" {
  description = "Whether to create/attach the GitHub Actions runtime destroy policy"
  type        = bool
  default     = false
}

variable "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role (OIDC) to attach destroy permissions to"
  type        = string
  default     = ""
}


