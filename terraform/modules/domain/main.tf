# Setting up CNAME record
resource "cloudflare_record" "ecs_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  type    = var.record_type
  value   = var.alb_dns
  ttl     = var.time_to_live
}
