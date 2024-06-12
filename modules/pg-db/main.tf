variable "core" {
  description = "Core module outputs"
  #type        = object(any)
}

variable "name" {
  description = "The name of the PostgreSQL instance."
  type        = string
}

resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}



resource "azurerm_postgresql_server" "pg_server" {
  name                = "${var.name}${random_string.server_suffix.result}"
  location            = var.core.location
  resource_group_name = var.core.rg.name
  administrator_login = "adminuser"
  administrator_login_password = "H@Sh1CoR3!"
  sku_name            = "B_Gen5_2"
  version             = "11"
  storage_mb          = 5120
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled = true
  ssl_enforcement_enabled = true
}

resource "azurerm_postgresql_database" "pg_db" {
  name                = "exampledb"
  resource_group_name = var.core.rg.name
  server_name         = azurerm_postgresql_server.pg_server.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
}

output "pg_server" {
  value = azurerm_postgresql_server.pg_server
}

output "pg_db" {
  value = azurerm_postgresql_database.pg_db
}

