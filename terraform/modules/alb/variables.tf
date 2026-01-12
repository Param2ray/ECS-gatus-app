variable "name" {
  description = "ALB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

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
  description = "Target port for the application (e.g., ECS task port)"
  type        = number
  default     = 8080
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate from ACM"
  type        = string
}