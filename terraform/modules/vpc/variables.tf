variable "name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
}

variable "az_count" {
  description = "Availability Zone count"
  type        = number
}

variable "public_subnet_cidrs" {
  description = "Public subnet cidr blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet cidr blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}