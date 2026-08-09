terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# Credentials come from the `az login` session, never hardcoded.
# subscription_id is mandatory in azurerm 4.x.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
