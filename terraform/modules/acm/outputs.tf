# Output the ARN of the ACM certificate

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "domain_validation_options" {
  description = "ACM DNS validation options (record name/type/value)"
  value       = aws_acm_certificate.cert.domain_validation_options
}