# Create an IAM role for ECS tasks to acces ECR image
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  }

# Attach the AmazonECSTaskExecutionRolePolicy managed policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub Actions OIDC thumbprint (commonly used)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # IMPORTANT: repo must match OWNER/REPO exactly
            "token.actions.githubusercontent.com:sub" = "repo:Param2ray/ecs-production-healthcheck-service:*"
          }
        }
      }
    ]
  })
}

# ECR permissions (needed for build -> push)
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# ECS permissions (needed later for deployments)
data "aws_iam_policy" "ecs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = data.aws_iam_policy.ecs_full_access.arn
}

