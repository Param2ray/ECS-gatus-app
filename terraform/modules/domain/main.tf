# Setting up CNAME record
resource "cloudflare_dns_record" "ecs_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  type    = var.record_type
  content = var.alb_dns
  ttl     = var.time_to_live
}
