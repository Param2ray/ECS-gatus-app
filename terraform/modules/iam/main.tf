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
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
      },
      {
        Sid    = "ELBv2RuntimeDestroy"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSRuntimeDestroy"
        Effect = "Allow"
        Action = [
          "ecs:Describe*",
          "ecs:List*",
          "ecs:UpdateService",
          "ecs:DeleteService",
          "ecs:DeleteCluster",
          "ecs:DeregisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Sid    = "ACMRuntimeDestroy"
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:ListTagsForCertificate",
          "acm:DeleteCertificate"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsRuntimeDestroy"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:DeleteLogGroup"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMRuntimeDetachOnly"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_runtime_destroy_attach" {
  count = var.enable_destroy_policy ? 1 : 0

  role       = var.github_actions_role_name
  policy_arn = aws_iam_policy.github_actions_runtime_destroy[0].arn
}














