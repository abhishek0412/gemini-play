terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestorage"
    container_name      = "tfstate"
    key                 = "gemini-play.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "gemini-play-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "geminiplaystorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security enhancements
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Deny"
    ip_rules       = ["your.ip.address.here"]
  }

  tags = {
    Environment = "Development"
    Project     = "gemini-play"
  }
}
