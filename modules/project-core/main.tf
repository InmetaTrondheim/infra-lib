resource "azurerm_resource_group" "core_rg" {
  name     = "${var.project_name}-rg"
  location = var.location
}
module "vnet" {
  source = "../vnet"
  core = {
    rg            = azurerm_resource_group.core_rg
    project_name  = var.project_name
    address_space = var.address_space
  }
}

module "storage_account" {
  source = "../storage-account"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
  }
}

## container app environment move to module
resource "azurerm_container_app_environment" "core_aca_env" {
  name                       = "ACA-Environment"
  location                   = azurerm_resource_group.core_rg.location
  resource_group_name        = azurerm_resource_group.core_rg.name
  infrastructure_subnet_id   = module.vnet.subnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core_log_analytics.id
}

module "key-vault" {
  source = "../key-vault"
  core = {
    rg           = azurerm_resource_group.core_rg
    project_name = var.project_name
    environment  = var.environment
  }
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
  value = azurerm_container_app_environment.core_aca_env
}

output "rg" {
  value = azurerm_resource_group.core_rg
}

output "vnet" {
  value = module.vnet.vnet
}

output "subnet" {
  value = module.vnet.subnet
}

output "address_space" {
  value = var.address_space
}
