# Create a security group for ECS tasks
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow HTTP traffic from the load balancer"
  vpc_id      = var.vpc_id
    ingress {
        from_port   = var.container_port
        to_port     = var.container_port
        protocol    = "tcp"
        security_groups = [var.alb_security_group_id]

    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create an ECS task definition
resource "aws_ecs_task_definition" "ecs_task" {
    family                   = "project_task_definition"
    network_mode             = "awsvpc"
    requires_compatibilities = [var.ecs_launch_type]
    cpu                      = var.cpu
    memory                   = var.memory
    
    container_definitions = jsonencode([
        {
        name      = var.task_name
        image     = var.image_url
        portMappings = [
            {
            containerPort = var.container_port
            hostPort      = var.container_port
            protocol      = "tcp"
            }
        ]
        }
    ])
    tags = {
        Name = "Project_task_definition"
    }
}

# Create an ECS service
resource "aws_ecs_service" "ecs_service" {
    name            = "project_ecs_service"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.ecs_task.arn
    desired_count   = 2
    launch_type     = var.ecs_launch_type

    network_configuration {
        subnets         = var.private_subnet_ids
        security_groups = [aws_security_group.ecs_sg.id]
        assign_public_ip = false
    }

    load_balancer {
        container_name   = var.container_name
        container_port   = var.container_port
    }
    tags = {
        Name = "Project_ecs_service"
    }  
}