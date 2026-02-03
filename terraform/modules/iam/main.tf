data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name                  = var.github_actions_role_name
  assume_role_policy    = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration  = 3600
  force_detach_policies = false
}

resource "aws_iam_role_policy" "github_actions_terraform_read" {
  name = "terraform-read-refresh"
  role = aws_iam_role.github_actions_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ACMRead"
        Effect   = "Allow"
        Action   = ["acm:DescribeCertificate", "acm:ListCertificates", "acm:ListTagsForCertificate"]
        Resource = "*"
      },
      {
        Sid    = "ELBv2Read"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsRead"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMRead"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_terraform_deploy" {
  name = "terraform-deploy-runtime"
  role = aws_iam_role.github_actions_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Sid    = "ACMWrite"
        Effect = "Allow"
        Action = [
          "acm:RequestCertificate",
          "acm:DeleteCertificate",
          "acm:AddTagsToCertificate",
          "acm:RemoveTagsFromCertificate"
        ]
        Resource = "*"
      },

      {
        Sid    = "CloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:TagLogGroup",
          "logs:UntagLogGroup"
        ]
        Resource = "*"
      },

      {
        Sid    = "ECSWrite"
        Effect = "Allow"
        Action = [
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:CreateService",
          "ecs:UpdateService",
          "ecs:DeleteService",
          "ecs:TagResource",
          "ecs:UntagResource"
        ]
        Resource = "*"
      },

      {
        Sid    = "ELBv2Write"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",

          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",

          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener",

          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]
        Resource = "*"
      },

      {
        Sid    = "EC2VpcNetworkingWrite"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",

          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute",

          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",

          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:ReplaceRouteTableAssociation",

          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",

          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",

          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",

          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },

      {
        Sid    = "IAMWriteForTerraform"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:TagPolicy",
          "iam:UntagPolicy",

          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:TagRole",
          "iam:UntagRole"
        ]
        Resource = "*"
      },

      {
        Sid      = "AllowPassRoleToECS"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },

      {
        Sid      = "SSMReadEcsSecrets"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/ecs_secrets"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_runtime_destroy" {
  count = var.enable_destroy_policy ? 1 : 0

  name        = "github-actions-runtime-destroy"
  description = "Allow GitHub Actions to destroy runtime infra (VPC/ALB/ECS/ACM/Logs)."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2RuntimeDestroy"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:DeleteSecurityGroup",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DisassociateRouteTable",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:DeleteRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRouteTable",
          "ec2:DeleteSubnet",
          "ec2:DeleteInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteNatGateway",
          "ec2:ReleaseAddress",
          "ec2:DeleteVpc",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_runtime_destroy_attach" {
  count = var.enable_destroy_policy ? 1 : 0

  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_runtime_destroy[0].arn
}

















