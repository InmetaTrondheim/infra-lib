variable "core" {
  description = "Core module outputs"
}

variable "name" {
  description = "The name of the Container App."
  type        = string
}

variable "db" {
  description = "Database module outputs"
}


resource "azurerm_container_group" "aca" {
  name                = var.name
  location            = var.core.location
  resource_group_name = var.core.rg.name
  os_type             = "Linux"

  container {
    name   = "aca-container"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      POSTGRES_HOST     = var.db.pg_server.fqdn
      POSTGRES_DB       = var.db.pg_db.name
      POSTGRES_USER     = "adminuser"
      POSTGRES_PASSWORD = "H@Sh1CoR3!"
    }
  }

  tags = {
    environment = "testing"
  }
}

output "aca" {
  value = azurerm_container_group.aca
}

