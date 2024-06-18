variable "core" {
  description = "Core module outputs"
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

resource "azurerm_postgresql_flexible_server" "pg_server" {
  name                   = "${var.name}${random_string.server_suffix.result}"
  location               = var.core.location
  resource_group_name    = var.core.rg.name
  administrator_login    = "adminuser"
  administrator_password = "H@Sh1CoR3!"
  sku_name               = "GP_Standard_D2s_v3"
  version                = "11"
  storage_mb             = 32768
  backup_retention_days  = 7
  high_availability {
    mode = "SameZone"
  }
  public_network_access_enabled = false # Ensure this is set to false for private access
  delegated_subnet_id           = var.core.subnet.id
  private_dns_zone_id           = var.core.private_dns_zone.id
}

resource "azurerm_postgresql_flexible_server_database" "pg_db" {
  name      = var.name
  server_id = azurerm_postgresql_flexible_server.pg_server.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "pg_db_diagnostic" {
  name               = "pg-db-diagnostic"
  target_resource_id = azurerm_postgresql_flexible_server.pg_server.id
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

output "pg_db" {
  value = azurerm_postgresql_flexible_server_database.pg_db
}
