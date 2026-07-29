# Look up the existing Route 53 public hosted zone
data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = false
}

# Request an ACM certificate for the ECS domain
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create ACM validation records in Route 53
resource "aws_route53_record" "acm_cert_validation" {
  for_each = var.manage_validation_records ? {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = var.ttl
  records = [each.value.record]

  allow_overwrite = true
}

# Wait until ACM confirms that the certificate is validated
resource "aws_acm_certificate_validation" "cert_validation" {
  count = var.manage_validation_records ? 1 : 0

  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    for record in aws_route53_record.acm_cert_validation :
    record.fqdn
  ]
}


