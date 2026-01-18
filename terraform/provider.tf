terraform {
  required_version = ">= 1.9.8"

  required_providers {
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }

    # Cloudflare Provider
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # S3 Backend Configuration
  backend "s3" {
    bucket         = "ece-production-healthcheck-service"
    key            = "terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "ca-central-1"

}

# Cloudflare Provider Configuration
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}