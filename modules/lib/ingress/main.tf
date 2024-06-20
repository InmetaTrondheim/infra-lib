variable "core" {
  description = "Core module outputs"
}

variable "name" {
  description = "The name of the Ingress resource."
  type        = string
}

variable "target" {
  description = "Target module outputs"
  type        = map(any)
}

variable "url" {
  description = "The URL to route traffic to."
  type        = string
}


#resource "azurerm_application_gateway" "appgw" {
#  name                = var.name
#  location            = var.core["location"]
#  resource_group_name = var.core["rg"]["name"]
#  sku {
#    name     = "WAF_v2"
#    tier     = "WAF_v2"
#    capacity = 2
#  }
#  gateway_ip_configuration {
#    name      = "appgw-ipcfg"
#    subnet_id = var.core["subnet"]["id"]
#  }
#  frontend_ip_configuration {
#    name                 = "appgw-frontend-ip"
#    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
#  }
#  frontend_port {
#    name = "frontendport"
#    port = 80
#  }
##  backend_address_pool {
##    name = "backendpool"
##    backend_addresses {
##      fqdn = var.target["aca"]["fqdn"]
##    }
#  }
#  backend_http_settings {
#    name                  = "backendhttpsettings"
#    cookie_based_affinity = "Disabled"
#    port                  = 80
#    protocol              = "Http"
#    request_timeout       = 60
#  }
#  http_listener {
#    name                           = "httplistener"
#    frontend_ip_configuration_name = "appgw-frontend-ip"
#    frontend_port_name             = "frontendport"
#    protocol                       = "Http"
#  }
#  request_routing_rule {
#    name               = "rulename"
#    rule_type          = "Basic"
#    http_listener_name = "httplistener"
#    backend_address_pool_name = "backendpool"
#    backend_http_settings_name = "backendhttpsettings"
#  }
#}

resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "${var.name}-pip"
  location            = var.core.location
  resource_group_name = var.core.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#output "appgw" {
#  value = azurerm_application_gateway.appgw
#}

