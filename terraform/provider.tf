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

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Cloudflare Provider Configuration
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}