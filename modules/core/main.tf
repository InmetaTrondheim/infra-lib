resource "azurerm_resource_group" "core_rg" {
  name     = "${var.project_name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "core_vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.core_rg.name
}

# Subnet Example
resource "azurerm_subnet" "core_subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.core_rg.name
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  # address_prefixes     = ["10.0.0.0/22"]
  address_prefixes = [cidrsubnet(var.address_space[0], 2, 0)] # 10.0.0.0/22

  delegation {
    name = "postgresqlDelegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        # "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action"
      ]
    }
  }
}
resource "azurerm_subnet" "core_subnet_container" {
  name                 = "container-subnet"
  resource_group_name  = azurerm_resource_group.core_rg.name
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  address_prefixes     = [cidrsubnet(var.address_space[0], 2, 1)] # 10.0.0.0/22
}

# Network Security Group
resource "azurerm_network_security_group" "nsg_app" {
  name                = "app-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.core_rg.name
}

# Link NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.core_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}


resource "azurerm_storage_account" "core_storage" {
  name                     = "tfstate${var.project_name}"
  resource_group_name      = azurerm_resource_group.core_rg.name
  location                 = azurerm_resource_group.core_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "core_storage_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.core_storage.name
  container_access_type = "private"
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "${var.project_name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.core_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  name                  = "dns-zone-link"
  resource_group_name   = azurerm_resource_group.core_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.core_vnet.id
}

resource "azurerm_container_app_environment" "core_aca_env" {
  name                     = "ACA-Environment"
  location                 = azurerm_resource_group.core_rg.location
  resource_group_name      = azurerm_resource_group.core_rg.name
  infrastructure_subnet_id = azurerm_subnet.core_subnet_container.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core_log_analytics.id
}

output "aca_env" {
  value = azurerm_container_app_environment.core_aca_env
}

output "rg" {
  value = azurerm_resource_group.core_rg
}

output "vnet" {
  value = azurerm_virtual_network.core_vnet
}

output "subnet" {
  value = azurerm_subnet.core_subnet
}

output "address_space" {
  value = azurerm_virtual_network.core_vnet.address_space
}

output "location" {
  value = azurerm_virtual_network.core_vnet.location
}

output "private_dns_zone" {
  value = azurerm_private_dns_zone.dns_zone
}
