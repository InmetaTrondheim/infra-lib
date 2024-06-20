variable "location" {
  description = "The location where resources will be created."
  type        = string
}

variable "project_name" {
  description = "The name of the project to which resources are tied."
  type        = string
}

variable "storage_containers" {
  description = "The storage containers to create."
  type        = list(string)
  default     = ["tfstate-common"]
}

resource "azurerm_resource_group" "tenant_core_rg" {
  name     = "${var.tenant_name}-rg"
  location = var.location
}

module "storage_account" {
  source = "../lib/storage-account"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
  }
  storage_containers = var.storage_containers
}

module "monitoring" {
  source = "../lib/monitoring"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
    environment  = "common"
  }
}

module "key-vault" {
  source = "../lib/key-vault"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
    environment  = "common"
  }
}

output "project_name" {
  value = var.project_name
}

output "environment" {
  value = "common"
}

output "kv" {
  value = module.key-vault.kv
}

output "rg" {
  value = azurerm_resource_group.core_rg
}
