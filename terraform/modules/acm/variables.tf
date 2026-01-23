variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for ACM certificate"
  type        = string
}

variable "ttl" {
  description = "TTL for ACM validation DNS record"
  type        = number
  default     = 300
}

variable "zone_name" {
  description = "Base domain name (Cloudflare zone), e.g. paramjyot2ray.com"
  type        = string
}

variable "manage_validation_records" {
  description = "Whether Terraform should create DNS validation records in Cloudflare for ACM."
  type        = bool
  default     = false
}
