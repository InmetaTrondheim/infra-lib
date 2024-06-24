variable "core" {
  description = "Core module outputs"
}

variable "name" {
  description = "The name of the PostgreSQL instance."
  type        = string
}

variable "databases" {
  description = "The databases to create on the PostgreSQL instance."
  type        = list(string)
  default     = ["main"]
}

resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}
resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}|:;,.?"
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_string.password.result
  key_vault_id = var.core.kv.id
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = "adminuser"
  key_vault_id = var.core.kv.id
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "${var.core.project_name}.postgres.database.azure.com"
  resource_group_name = var.core.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  name                  = "dns-zone-link"
  resource_group_name   = var.core.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = var.core.vnet.id
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "db-subnet"
  resource_group_name  = var.core.rg.name
  virtual_network_name = var.core.vnet.name
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

resource "azurerm_postgresql_flexible_server" "pg_server" {
  name                   = "${var.name}${random_string.server_suffix.result}"
  location               = var.core.rg.location
  resource_group_name    = var.core.rg.name
  administrator_login    = azurerm_key_vault_secret.db_user.value
  administrator_password = azurerm_key_vault_secret.db_password.value
  sku_name               = "GP_Standard_D2s_v3"
  version                = "11"
  storage_mb             = 32768
  backup_retention_days  = 7
  high_availability {
    mode = "SameZone"
  }
  public_network_access_enabled = false # Ensure this is set to false for private access
  delegated_subnet_id           = resource.azurerm_subnet.db_subnet.id
  private_dns_zone_id           = resource.azurerm_private_dns_zone.dns_zone.id
}

resource "azurerm_postgresql_flexible_server_database" "pg_dbs" {
  for_each  = toset(var.databases)
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.pg_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
  # prevent the possibility of accidental data loss
  lifecycle {
    # prevent_destroy = true
  }
}


resource "azurerm_monitor_diagnostic_setting" "pg_db_diagnostic" {
  name                       = "pg-db-diagnostic"
  target_resource_id         = azurerm_postgresql_flexible_server.pg_server.id
  log_analytics_workspace_id = var.core.log_analytics.id
  log {
    category = "PostgreSQLLogs"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
}


output "pg_server" {
  value = azurerm_postgresql_flexible_server.pg_server
}

output "pg_dbs" {
  value = azurerm_postgresql_flexible_server_database.pg_dbs
}
