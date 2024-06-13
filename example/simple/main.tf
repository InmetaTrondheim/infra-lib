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

  # backend "azurerm" {
  #   resource_group_name  = "TerraformStateRG"
  #   storage_account_name = "tfstate${var.project_name}"
  #   container_name       = "tfstate"
  #   key                  = "core.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

module "core" {
  source        = "../../modules/core"
  project_name  = var.project_name
  location      = "West US"
  address_space = ["10.0.0.0/16"]
}


module "pg-db" {
  source = "../../modules/pg-db"
  core   = module.core
  name   = "pg-db"
}

resource "azurerm_container_app" "frontend" {
  name                         = "frontend"
  resource_group_name          = module.core.rg.name
  container_app_environment_id = module.core.aca_env.id
  revision_mode                = "Multiple"

  template {
    container {
      name   = "aca-container"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
      cpu    = "0.5"
      memory = "1Gi"


      env {
        name  = "BACKEND_HOST"
        value = "http://url:80"
      }
    }
  }
  ingress {
    target_port = 80
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
      name   = "aca-container"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
      cpu    = "0.5"
      memory = "1Gi"


      env {
        name  = "POSTGRES_HOST"
        value = module.pg-db.pg_server.fqdn
      }
      env {
        name  = "POSTGRES_DB"
        value = module.pg-db.pg_db.name
      }
      env {
        name  = "POSTGRES_USER"
        value = "adminuser"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = "H@Sh1CoR3!"
      }
    }
  }
  ingress {
    target_port = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
