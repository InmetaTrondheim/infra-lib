variable "location" {
  description = "The location where resources will be created."
  type        = string
}

variable "project_name" {
  description = "The name of the project to which resources are tied."
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

resource "azurerm_virtual_network" "core_vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.core_rg.name
}

# Subnet Example
resource "azurerm_subnet" "core_subnet"{
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.core_rg.name
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
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
