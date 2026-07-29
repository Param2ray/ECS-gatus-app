output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.application_lb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.project_alb.arn
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.project_alb_listeners.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.sg_alb.id
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB"
  value       = aws_lb.application_lb.zone_id
}

