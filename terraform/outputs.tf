output "github_actions_role_arn" {
  description = "IAM role ARN GitHub Actions assumes via OIDC"
  value       = module.iam.github_actions_role_arn
}

