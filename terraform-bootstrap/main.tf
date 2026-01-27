provider "aws" {
  region = var.aws_region
}

# Use the existing GitHub OIDC provider (do NOT try to create it in main stack)
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Role GitHub Actions assumes via OIDC
resource "aws_iam_role" "github_actions" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

# Policy: allow Terraform to read/write remote state (S3) and use DynamoDB locking
resource "aws_iam_policy" "terraform_backend" {
  name        = "terraform-backend-access"
  description = "Access to Terraform S3 state and DynamoDB lock table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StateBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.state_bucket}"
      },
      {
        Sid    = "StateObjectRW"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.state_bucket}/*"
      },
      {
        Sid    = "TerraformLockTable"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = var.lock_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backend_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_backend.arn
}

# ✅ FIX for your errors:
# Allow GitHub Actions role to read SSM parameter + read IAM role during terraform plan/apply
resource "aws_iam_policy" "github_actions_extra" {
  name        = "github-actions-extra-permissions"
  description = "SSM + IAM read permissions needed by Terraform from GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadEcsSecretsFromSSM"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:512378127667:parameter/ecs_secrets"
      },
      {
        Sid      = "ReadEcsExecutionRole"
        Effect   = "Allow"
        Action   = ["iam:GetRole"]
        Resource = "arn:aws:iam::512378127667:role/ecsTaskExecutionRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_extra_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_extra.arn
}

