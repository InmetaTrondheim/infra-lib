variable "project_name" {
  type    = string
  default = "myproject"
}
variable "location" {
  type    = string
  default = "North Europe"
}
variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  # uncomment once backend is created
  backend "azurerm" {
    resource_group_name  = "common-rg"
    storage_account_name = "common0xg9"
    container_name       = "tfstate-app1"
    key                  = "common.terraform.tfstate"
  }

  # uncomment once backend is created
  # backend "azurerm" {
  #   resource_group_name  = # get value for storage created in tenant-bootstrap
  #   storage_account_name = # get value for storage created in tenant-bootstrap
  #   container_name       = # get value for storage created in tenant-bootstrap
  #   key                  = # get value for storage created in tenant-bootstrap
  # }

}

provider "azurerm" {
  features {}
}

module "core" {
  source        = "../../modules/project-core"
  project_name  = var.project_name
  location      = "West US"
  address_space = ["10.0.0.0/16"]
  environment   = "dev"
}


module "pg-db" {
  source    = "../../modules/lib/pg-db"
  core      = module.core
  name      = "pg-db"
  databases = ["main"]
}

resource "azurerm_container_app" "frontend" {
  name                         = "frontend"
  resource_group_name          = module.core.rg.name
  container_app_environment_id = module.core.aca_env.id
  revision_mode                = "Multiple"

  template {
    container {
      name   = "frontend"
      image  = "ghcr.io/marnyg/frontend:latest"
      cpu    = "0.5"
      memory = "1Gi"


      env {
        name  = "BACKEND_HOST"
        value = azurerm_container_app.backend.latest_revision_fqdn

      }
      env {
        name  = "BACKEND_PORT"
        value = "80"
      }
    }
  }


  ingress {
    target_port                = 5000
    allow_insecure_connections = true
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "backend" {
  name                         = "backend"
  resource_group_name          = module.core.rg.name
  container_app_environment_id = module.core.aca_env.id
  revision_mode                = "Multiple"

  template {
    container {
      name   = "backend"
      image  = "ghcr.io/marnyg/backend:latest"
      cpu    = "0.5"
      memory = "1Gi"


      env {
        name  = "POSTGRES_HOST"
        value = module.pg-db.pg_server.fqdn
      }
      env {
        name  = "POSTGRES_DB"
        value = module.pg-db.pg_dbs.main.name
      }
      env {
        name  = "POSTGRES_USER"
        value = module.pg-db.pg_server.administrator_login
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = module.pg-db.pg_server.administrator_password
      }
    }
  }

  ingress {
    target_port                = 5001
    allow_insecure_connections = true
    external_enabled           = false
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
