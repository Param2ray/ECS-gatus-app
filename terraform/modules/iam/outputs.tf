# Output the IAM role ARN
output "task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}