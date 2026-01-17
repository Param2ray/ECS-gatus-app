variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_launch_type" {
  description = "ECS launch type (FARGATE or EC2)"
  type        = string
  default     = "FARGATE"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "CPU units for ECS task"
  type        = number
}

variable "memory" {
  description = "Memory (MiB) for ECS task"
  type        = number

}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  }

variable "vpc_id" {
  description = "VPC ID where ECS will be deployed"
  type        = string
}

variable "http_listener_arn" {
  description = "ARN of the HTTP listener from ALB"
  type        = string
}

variable "https_listener_arn" {
  description = "ARN of the HTTPS listener from ALB"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for ECS task execution"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for the ALB"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
} 

variable "image_url" {
  type        = string
  description = "Name which you want to name your container"
  
}

variable "task_name" {
  description = "Name which you want to name your task"
  type        = string

}

variable "container_name" {
  description = "Name which you want to name your container"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM execution role ARN for ECS tasks (pull ECR, write logs)"
  type        = string
}

variable "task_family" {
  description = "ECS task family name"
  type        = string
}
