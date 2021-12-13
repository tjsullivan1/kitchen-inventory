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
  # TODO: Determine whether or not I need to document these design decisions somewhere.
  #checkov:skip=CKV2_AZURE_1:I don't want to use customer managed keys.
  #checkov:skip=CKV2_AZURE_18:I don't want to use customer managed keys.

  # TODO: More research is needed on this one.
  #checkov:skip=CKV_AZURE_43:I don't think checkov is able to parse this string interpolated value.
  name                     = "sa${lower(var.disambiguation)}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.ki.name
  location                 = azurerm_resource_group.ki.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  #checkov:skip=CKV2_AZURE_8:This check is failing for the container, but the log container isn't explicitly defined. This setting should control that access.
  #TODO: At a later date, add explicit container definition for logs and ensure set properly.
  allow_blob_public_access  = false
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  network_rules {
    default_action = "Deny"
  }

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
  }

  queue_properties {
    logging {
      delete                = true
      write                 = true
      read                  = true
      version               = "1.0"
      retention_policy_days = 3
    }

    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 3
    }

    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 3
    }
  }

  tags = var.tags
}

resource "azurerm_key_vault" "ki" {
  #checkov:skip=CKV_AZURE_42:This is just a development instance. I don't want to enable purge protection on the Key Vault.
  #checkov:skip=CKV_AZURE_110:This is just a development instance. I don't want to enable purge protection on the Key Vault.
  name                        = "akv-${var.disambiguation}-${random_string.suffix.result}"
  location                    = azurerm_resource_group.ki.location
  resource_group_name         = azurerm_resource_group.ki.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  #checkov:skip=CKV_AZURE_109:With GitHub Actions hosted runners this section breaks terraform, since we don't have a list of all IPs for GitHub. You can get these by calling an API, but GitHub doesn't recommend using those for an allow list.
  #TODO: Figure out if I should be using self-hosted runners.
  # network_acls {
  #   default_action = "Deny"
  #   bypass         = "AzureServices"
  # }


  sku_name = "standard"
}

resource "azurerm_key_vault_secret" "storage-account-key" {
  name            = "${azurerm_storage_account.ki.name}-key"
  value           = azurerm_storage_account.ki.primary_access_key
  key_vault_id    = azurerm_key_vault.ki.id
  expiration_date = "2022-06-03T00:00:00Z"
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "storage-account-connection-string" {
  name            = "${azurerm_storage_account.ki.name}-connection-string"
  value           = azurerm_storage_account.ki.primary_connection_string
  key_vault_id    = azurerm_key_vault.ki.id
  expiration_date = "2022-06-03T00:00:00Z"
  content_type    = "text/plain"
}

