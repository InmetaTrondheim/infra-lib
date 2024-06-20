
resource "azurerm_log_analytics_workspace" "core_log_analytics" {
  name                = "core-log-analytics-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.core_rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_action_group" "core_action_group" {
  name                = "core-action-group-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.core_rg.name
  short_name          = var.project_name

  webhook_receiver {
    name        = "callmyapi"
    service_uri = "http://example.com/callback"
  }
}

output "log_analytics" {
  value = azurerm_log_analytics_workspace.core_log_analytics
}
