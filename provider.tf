# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.108.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}