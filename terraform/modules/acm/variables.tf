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

