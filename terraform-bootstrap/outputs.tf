output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.gatus_app.repository_url
}


