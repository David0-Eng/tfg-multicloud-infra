terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # testing native `aws login` credential support
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# Credentials are resolved from the `aws login` session, never hardcoded.
provider "aws" {
  region = var.aws_region
}
