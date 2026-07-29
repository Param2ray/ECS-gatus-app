variable "domain_name" {
  description = "Parent domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain used for the ACM certificate"
  type        = string
}

variable "hosted_zone_name" {
  description = "Existing Route 53 hosted zone name"
  type        = string
}

variable "ttl" {
  description = "TTL for ACM validation DNS records"
  type        = number
  default     = 300
}

variable "manage_validation_records" {
  description = "Whether Terraform should create Route 53 validation records for ACM"
  type        = bool
  default     = true
}