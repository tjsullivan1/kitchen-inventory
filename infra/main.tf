terraform {
  required_version = "~> 1.0.0"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 2.72.0"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.1.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tjs-payg-central-services-rg"
    storage_account_name = "tjspaygcentservicesblob"
    container_name       = "tfstate"
    key                  = "ki/terraform.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = false
  features {}
}

data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 4
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "ki" {
  name     = "rg-${var.disambiguation}-${random_string.suffix.result}"
  location = var.location

  tags = var.tags
}

resource "azurerm_storage_account" "ki" {
  name                      = "sa${lower(var.disambiguation)}${random_string.suffix.result}"
  resource_group_name       = azurerm_resource_group.ki.name
  location                  = azurerm_resource_group.ki.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
  }

  tags = var.tags
}

resource "azurerm_key_vault" "ki" {
  name                        = "akv-${var.disambiguation}-${random_string.suffix.result}"
  location                    = azurerm_resource_group.ki.location
  resource_group_name         = azurerm_resource_group.ki.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "spn" {
  key_vault_id   = azurerm_key_vault.ki.id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = var.spn_object_id
  application_id = var.spn_app_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = azurerm_key_vault.ki.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.me_object_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

resource "azurerm_key_vault_secret" "storage-account-key" {
  name         = "${azurerm_storage_account.ki.name}-key"
  value        = azurerm_storage_account.ki.primary_access_key
  key_vault_id = azurerm_key_vault.ki.id
}

resource "azurerm_key_vault_secret" "storage-account-connection-string" {
  name         = "${azurerm_storage_account.ki.name}-connection-string"
  value        = azurerm_storage_account.ki.primary_connection_string
  key_vault_id = azurerm_key_vault.ki.id
}

