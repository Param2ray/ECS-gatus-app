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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = "arn:aws:iam::512378127667:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Param2ray/ecs-production-healthcheck-service:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_state_access" {
  name        = "terraform-state-access"
  description = "Allow GitHub Actions to read/write Terraform remote state in S3 and lock in DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateS3ListBucket"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::ece-production-healthcheck-service"]
      },
      {
        Sid    = "TerraformStateS3Objects"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = ["arn:aws:s3:::ece-production-healthcheck-service/*"]
      },
      {
        Sid    = "TerraformStateDynamoLock"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:ca-central-1:512378127667:table/terraform-state-lock"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_state_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

resource "aws_iam_policy" "github_actions_runtime_destroy" {
  name        = "github-actions-runtime-destroy"
  description = "Allow GitHub Actions to destroy runtime infrastructure (VPC/ALB/ECS/ACM/Route53) but keep IAM/ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      
      {
        Sid    = "EC2Destroy"
        Effect = "Allow"
        Action = [
          "ec2:DeleteSecurityGroup",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",

          "ec2:DisassociateRouteTable",
          "ec2:DeleteRoute",
          "ec2:DeleteRouteTable",
          "ec2:ReplaceRoute",
          "ec2:ReplaceRouteTableAssociation",

          "ec2:DeleteSubnet",
          "ec2:DeleteInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteNatGateway",
          "ec2:ReleaseAddress",
          "ec2:DeleteVpc",

          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",

          "ec2:Describe*"
        ]
        Resource = "*"
      },

      {
        Sid    = "ELBv2Destroy"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },

      {
        Sid    = "ECSDestroy"
        Effect = "Allow"
        Action = [
          "ecs:DeleteCluster",
          "ecs:DeleteService",
          "ecs:DeregisterTaskDefinition",
          "ecs:Describe*",
          "ecs:List*",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },

      {
        Sid    = "ACMDestroy"
        Effect = "Allow"
        Action = [
          "acm:DeleteCertificate",
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate"
        ]
        Resource = "*"
      },

      {
        Sid    = "LogsDestroy"
        Effect = "Allow"
        Action = [
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_runtime_destroy_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_runtime_destroy.arn
}







