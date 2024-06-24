variable "core" {
  description = "Core module outputs"
}

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.core.name}0${random_string.storage_suffix.result}"
  resource_group_name = var.core.rg.name
  location            = var.core.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}

output "acr" {
  value = azurerm_container_registry.acr
}


