output "acm_certificate_arn" {
  description = "The ARN of the validated ACM certificate"

  value = var.manage_validation_records ? (
    aws_acm_certificate_validation.cert_validation[0].certificate_arn
  ) : aws_acm_certificate.cert.arn
}

output "domain_validation_options" {
  description = "ACM DNS validation options (record name/type/value)"
  value       = aws_acm_certificate.cert.domain_validation_options
}
