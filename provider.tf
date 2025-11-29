terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      # Для коректного видалення
      prevent_deletion_if_contains_resources = false
    }
  }
}