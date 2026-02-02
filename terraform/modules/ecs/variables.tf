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
  description = "Full container image URI (ECR repo + tag)"
}

variable "container_name" {
  description = "Container name in the task definition"
  type        = string
  default     = "gatus"
}

variable "task_family" {
  description = "ECS task family name"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM execution role ARN for ECS tasks (pull ECR, write logs)"
  type        = string
}

variable "execution_role_name" {
  description = "Name of the ECS task execution role (used for IAM policy attachments)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL (without tag)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag (usually Git SHA)"
  type        = string
}