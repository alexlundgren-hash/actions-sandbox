terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # These values are set via -backend-config flags in GitHub Actions workflow
    # to keep them out of version control
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-from-gh-actions"
  location = var.azure_region

  tags = {
    provisioned_by = "github-actions"
    environment    = "testing"
  }
}


resource "azurerm_resource_group" "new" {
  name     = "gh-actions"
  location = var.azure_region

  tags = {
    provisioned_by = "github-actions"
    environment    = "testing"
  }
}
