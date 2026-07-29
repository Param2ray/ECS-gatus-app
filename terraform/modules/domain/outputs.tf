output "record_hostname" {
  description = "The fully qualified ECS domain name"
  value       = aws_route53_record.ecs.fqdn
}
