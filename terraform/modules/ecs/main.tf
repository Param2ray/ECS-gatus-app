# 1) Read the existing SSM parameter you created manually
data "aws_ssm_parameter" "ecs_secrets" {
  name = "ecs_secrets"
}

# 2) Create an IAM policy to allow ECS tasks to read that parameter
resource "aws_iam_policy" "ecs_read_ssm" {
  name = "ecs-read-ssm-parameter"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = data.aws_ssm_parameter.ecs_secrets.arn
      }
    ]
  })
}
# 3) Attach the policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_read_ssm_attach" {
  role       = var.execution_role_name
  policy_arn = aws_iam_policy.ecs_read_ssm.arn
}

# 4) Security group for ECS tasks
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow HTTP traffic from the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5) ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# 6) ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image_url
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "ECS_SECRETS"
          valueFrom = data.aws_ssm_parameter.ecs_secrets.arn
        }
      ]
    }
  ])

  tags = {
    Name = "Project_task_definition"
  }
}

# 7) ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "project_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = var.ecs_launch_type

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = {
    Name = "Project_ecs_service"
  }
}
