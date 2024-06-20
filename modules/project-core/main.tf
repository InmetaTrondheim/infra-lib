variable "location" {
  description = "The location where resources will be created."
  type        = string
}

variable "project_name" {
  description = "The name of the project to which resources are tied."
  type        = string
}

variable "environment" {
  description = "The environment for the resources."
  type        = string
}

variable "address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
}



resource "azurerm_resource_group" "core_rg" {
  name     = "${var.project_name}-rg"
  location = var.location
}
# module "vnet" {
#   source = "../lib/vnet"
#   core = {
#     rg            = azurerm_resource_group.core_rg
#     project_name  = var.project_name
#     address_space = var.address_space
#   }
# }
resource "azurerm_virtual_network" "core_vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = var.address_space
  location            = azurerm_resource_group.core_rg.location
  resource_group_name = azurerm_resource_group.core_rg.name
}

module "monitoring" {
  source = "../lib/monitoring"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
    environment  = var.environment
  }
}

module "container-app-environment" {
  source = "../lib/container-app-environment"
  core = {
    rg            = azurerm_resource_group.core_rg
    vnet          = azurerm_virtual_network.core_vnet
    log_analytics = module.monitoring.log_analytics
  }
}

module "key-vault" {
  source = "../lib/key-vault"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
    environment  = var.environment
  }
}

output "log_analytics" {
  value = module.monitoring.log_analytics
}

output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "kv" {
  value = module.key-vault.kv
}

output "aca_env" {
  value = module.container-app-environment.aca_env
}

output "rg" {
  value = azurerm_resource_group.core_rg
}

output "vnet" {
  value = azurerm_virtual_network.core_vnet
}


output "address_space" {
  value = var.address_space
}
