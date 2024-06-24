variable "location" {
  description = "The location where resources will be created."
  type        = string
}

variable "tenant_name" {
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
module "monitoring" {
  source = "../lib/monitoring"
  core = {
    rg           = azurerm_resource_group.tenant_core_rg
    name = var.tenant_name
    environment  = "common"
  }
}

locals {
  core = {
    rg            = azurerm_resource_group.tenant_core_rg
    name  = var.tenant_name
    environment   = "common"
    log_analytics = module.monitoring.log_analytics
  }
}

module "storage_account" {
  source             = "../lib/storage-account"
  core               = local.core
  storage_containers = var.storage_containers
}


module "service-bus" {
  source = "../lib/service-bus"
  core   = local.core
}


module "container_registry" {
  source = "../lib/container-registry"
  core   = local.core
}

module "key-vault" {
  source = "../lib/key-vault"
  core   = local.core
}

output "name" {
  value = var.tenant_name
}

output "environment" {
  value = "common"
}

output "kv" {
  value = module.key-vault.kv
}

output "rg" {
  value = azurerm_resource_group.tenant_core_rg
}

output "storage_account" {
  value = module.storage_account.storage_account
}

output "container_registry" {
  value = module.container_registry.acr
}

