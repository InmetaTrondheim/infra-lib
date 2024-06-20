variable "core" {
  description = "The core module"
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "core_key_vault" {
  name                = "core-kv-${var.core.project_name}-${var.core.environment}"
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]

    certificate_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}


output "kv" {
  value = azurerm_key_vault.core_key_vault
}
