output "record_hostname" {
  value = "${cloudflare_dns_record.ecs_record.name}.${var.zone_name}"
}
