variable "core" {
  description = "Core module outputs"
}

variable "name" {
  description = "The name of the Service Bus namespace and the queue."
  type        = string
}

resource "azurerm_service_bus_namespace" "sb_namespace" {
  name                = "${var.name}${random_string.namespace_suffix.result}"
  location            = var.core.rg.location
  resource_group_name = var.core.rg.name
  sku                 = "Standard" # Can be Basic, Standard, or Premium
}

resource "random_string" "namespace_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_service_bus_queue" "sb_queue" {
  name                = var.name
  resource_group_name = var.core.rg.name
  namespace_name      = azurerm_service_bus_namespace.sb_namespace.name

  # Example settings - these should be adjusted to fit actual use case requirements
  max_size_in_megabytes                   = 1024
  lock_duration                           = "PT5M"
  duplicate_detection_history_time_window = "PT1M"
  enable_partitioning                     = true
}

resource "azurerm_monitor_diagnostic_setting" "sb_diagnostic" {
  name                       = "sb-queue-diagnostic"
  target_resource_id         = azurerm_service_bus_namespace.sb_namespace.id
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

output "service_bus_namespace" {
  value = azurerm_service_bus_namespace.sb_namespace
}

output "service_bus_queue" {
  value = azurerm_service_bus_queue.sb_queue
}

