variable "core" {
  description = "Core variables"
}

resource "azurerm_log_analytics_workspace" "core_log_analytics" {
  name                = "core-log-analytics-${var.core.name}-${var.core.environment}"
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_action_group" "core_action_group" {
  name                = "core-action-group-${var.core.name}-${var.core.environment}"
  resource_group_name = var.core.rg.name
  short_name          = var.core.name

  webhook_receiver {
    name        = "callmyapi"
    service_uri = "http://example.com/callback"
  }
}

output "log_analytics" {
  value = azurerm_log_analytics_workspace.core_log_analytics
}
