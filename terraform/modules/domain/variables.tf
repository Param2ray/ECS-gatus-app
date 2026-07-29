variable "hosted_zone_name" {
  description = "Existing Route 53 hosted zone name"
  type        = string
}

variable "record_name" {
  description = "Fully qualified ECS application domain"
  type        = string
}

variable "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "Application Load Balancer canonical hosted zone ID"
  type        = string
}