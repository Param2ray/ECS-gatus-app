# Setting up ACM for ALB
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "acm_cert_validation" {
  for_each = var.manage_validation_records ? {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      content = dvo.resource_record_value
      type    = dvo.resource_record_type
      proxied = false
    }
  } : {}


  zone_id = var.cloudflare_zone_id
  name    = trimsuffix(replace(each.value.name, ".${var.zone_name}", ""), ".")
  type    = each.value.type
  content = trimsuffix(each.value.content, ".")
  ttl     = var.ttl
  proxied = false
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count = var.manage_validation_records ? 1 : 0

  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    for record in cloudflare_dns_record.acm_cert_validation : record.name
  ]
}


