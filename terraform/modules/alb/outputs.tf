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

output "alb_security_group_id" {
  description = "The ID of the security group associated with the ALB"
  value       = aws_security_group.sg_alb.id
}
