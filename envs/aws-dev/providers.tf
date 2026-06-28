terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # stay on 5.x; avoid breaking changes from 6.0
    }
  }
}

# Credentials are resolved from the `aws login` session, never hardcoded.
provider "aws" {
  region = var.aws_region
}
