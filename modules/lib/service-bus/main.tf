variable "core" {
  description = "Core module outputs"
}

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "${var.core.name}${random_string.namespace_suffix.result}"
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
  sku                 = "Standard" # Can be Basic, Standard, or Premium
}

resource "random_string" "namespace_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_servicebus_queue" "sb_queue" {
  name         = var.core.name
  namespace_id = azurerm_servicebus_namespace.sb_namespace.id

  # Example settings - these should be adjusted to fit actual use case requirements
  max_size_in_megabytes                   = 1024
  lock_duration                           = "PT5M"
  duplicate_detection_history_time_window = "PT1M"
  enable_partitioning                     = true
}

resource "azurerm_monitor_diagnostic_setting" "sb_diagnostic" {
  name                       = "sb-queue-diagnostic"
  target_resource_id         = azurerm_servicebus_namespace.sb_namespace.id
  log_analytics_workspace_id = var.core.log_analytics.id

  log {
    category = "OperationalLogs"
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

output "servicebus_namespace" {
  value = azurerm_servicebus_namespace.sb_namespace
}

output "servicebus_queue" {
  value = azurerm_servicebus_queue.sb_queue
}

