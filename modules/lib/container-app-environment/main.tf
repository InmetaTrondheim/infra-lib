variable "core" {
  description = "The core module"
}

resource "azurerm_subnet" "container_subnet" {
  name                 = "container-subnet"
  resource_group_name  = var.core.rg.name
  virtual_network_name = var.core.vnet.name
  address_prefixes     = [cidrsubnet(var.core.vnet.address_space[0], 2, 1)] # 
}
resource "azurerm_network_security_group" "nsg_app" {
  name                = "app-nsg"
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.core.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_app.name
}
resource "azurerm_network_security_rule" "https" {
  name = "https"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.core.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_app.name
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.container_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

resource "azurerm_container_app_environment" "core_aca_env" {
  name                       = "ACA-Environment"
  location                   = var.core.rg.location
  resource_group_name        = var.core.rg.name
  infrastructure_subnet_id   = azurerm_subnet.container_subnet.id
  log_analytics_workspace_id = var.core.log_analytics.id
}


output "aca_env" {
  value = azurerm_container_app_environment.core_aca_env
}
