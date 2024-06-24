variable "core" {
  description = "Core variables"
}

variable "storage_containers" {
  description = "The storage containers to create."
  type        = list(string)
  default     = ["tfstate-common"]
}

resource "random_string" "storage_suffix" {
  #can only consist of lowercase letters and numbers, and must be between 3 and 24 characters long
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_storage_account" "core_storage" {
  name                     = "${var.core.project_name}0${random_string.storage_suffix.result}"
  resource_group_name      = var.core.rg.name
  location                 = var.core.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "core_storage_containers" {
  for_each              = toset(var.storage_containers)
  name                  = each.key
  storage_account_name  = azurerm_storage_account.core_storage.name
  container_access_type = "private"
}

output "storage_account" {
  value = azurerm_storage_account.core_storage
}
