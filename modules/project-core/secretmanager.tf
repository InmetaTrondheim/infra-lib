#
# data "azurerm_client_config" "current" {}
#
# resource "azurerm_key_vault" "core_key_vault" {
#   name                = "core-kv-${var.project_name}-${var.environment}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.core_rg.name
#   tenant_id           = data.azurerm_client_config.current.tenant_id
#   sku_name            = "standard"
#
#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id
#
#     key_permissions = [
#       "Get",
#     ]
#
#     secret_permissions = [
#       "Get",
#       "List",
#       "Set",
#     ]
#
#     certificate_permissions = [
#       "Get",
#     ]
#
#     storage_permissions = [
#       "Get",
#     ]
#   }
# }
#
#
# output "kv" {
#   value = azurerm_key_vault.core_key_vault
# }
