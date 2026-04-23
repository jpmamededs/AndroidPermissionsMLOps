terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~>4.0"
      }
      random = {
        source = "hashicorp/random"
        version = "~>3.0"
      }
    }
}

provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
    length  = 6
    special = false
    upper   = false
}

resource "azurerm_resource_group" "resourcegroup" {
    name = "MLOpsProject-${random_string.suffix.result}"
    location = "East US"
}

resource "azurerm_application_insights" "appinsights" {
    name = "mlopsAppInsights"
    location = azurerm_resource_group.resourcegroup.location
    resource_group_name = azurerm_resource_group.resourcegroup.name
    application_type = "web"
}

resource "azurerm_key_vault" "keyvault" {
    name = "mlops-kv-${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.resourcegroup.name
    tenant_id = data.azurerm_client_config.current.tenant_id
    location = azurerm_resource_group.resourcegroup.location
    sku_name = "standard"
}

resource "azurerm_storage_account" "storageaccount" {
    name = "mlopsst${random_string.suffix.result}"
    location = azurerm_resource_group.resourcegroup.location
    resource_group_name = azurerm_resource_group.resourcegroup.name
    account_tier = "Standard"
    account_replication_type = "GRS"
}

resource "azurerm_machine_learning_workspace" "mlworkspace" {
    name = "mlopsworkspace"
    location = azurerm_resource_group.resourcegroup.location
    resource_group_name = azurerm_resource_group.resourcegroup.name
    application_insights_id = azurerm_application_insights.appinsights.id
    key_vault_id = azurerm_key_vault.keyvault.id
    storage_account_id = azurerm_storage_account.storageaccount.id

    identity {
        type = "SystemAssigned"
    }

}