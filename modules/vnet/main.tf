variable "core" {
  description = "The core module"
}


resource "azurerm_virtual_network" "core_vnet" {
  name                = "${var.core.project_name}-vnet"
  address_space       = var.core.address_space
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
}

# Subnet Example
resource "azurerm_subnet" "core_subnet" {
  name                 = "app-subnet"
  resource_group_name  = var.core.rg.name
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  address_prefixes     = [cidrsubnet(var.core.address_space[0], 2, 0)] # 10.0.0.0/22

  delegation {
    name = "postgresqlDelegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "core_subnet_container" {
  name                 = "container-subnet"
  resource_group_name  = var.core.rg.name
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  address_prefixes     = [cidrsubnet(var.core.address_space[0], 2, 1)] # 10.0.0.0/22
}

resource "azurerm_network_security_group" "nsg_app" {
  name                = "app-nsg"
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.core_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

output "vnet" {
  value = azurerm_virtual_network.core_vnet
}
output "subnet" {
  value = azurerm_subnet.core_subnet
}
