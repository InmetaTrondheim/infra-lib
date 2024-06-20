variable "core" {
  description = "Core variables"
}

resource "random_string" "storage_suffix" {
  length  = 3
  special = false
  lower   = true
}

resource "azurerm_storage_account" "core_storage" {
  name                     = "tfstate-${var.core.project_name}-${random_string.storage_suffix.result}"
  resource_group_name      = var.core.rg.name
  location                 = var.core.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "core_storage_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.core_storage.name
  container_access_type = "private"
}
