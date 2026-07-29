terraform {
  required_version = ">= 1.10.0"

  required_providers {
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }

  # S3 Backend Configuration
  backend "s3" {
    bucket       = "ecs-production-healthcheck-service"
    key          = "terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}