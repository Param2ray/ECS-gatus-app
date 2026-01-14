# VPC variables

variable "name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
}

variable "az_count" {
  description = "Availability Zone count"
  type        = number
}

variable "public_subnet_cidrs" {
  description = "Public subnet cidr blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet cidr blocks"
  type        = list(string)
}

# Domain/Cloudflare variables

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "cloudflare_account_id" {
  description = "The Cloudflare Account ID"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for ACM certificate"
  type        = string
}

# ALB and app variables

variable "http_listener_port" {
  description = "HTTP listener port"
  type        = number
  default     = 80
}

variable "https_listener_port" {
  description = "HTTPS listener port"
  type        = number
  default     = 443
}

variable "container_port" {
  description = "Container port for ECS service"
  type        = number
  default     = 8080
}

# ECS variables

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
  description = "Memory for ECS task"
  type        = number
}

variable "image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "ttl" {
  type        = number
  description = "DNS record TTL"
  default     = 300
}

variable "task_name" {
  description = "ECS task definition name"
  type        = string
}