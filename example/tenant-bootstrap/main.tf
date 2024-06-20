variable "project_name" {
  type    = string
  default = "tennant-common"
}
variable "location" {
  type    = string
  default = "North Europe"
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
  #   resource_group_name  = module.tenant-core.tenant_core_rg.name
  #   storage_account_name = module.tenant-core.storage_account.core.name
  #   container_name       = "tfstate-common"
  #   key                  = "core.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

module "tenant-core" {
  source             = "../../modules/company-core"
  project_name       = var.project_name
  location           = "West US"
  storage_containers = ["tfstate-common", "tfstate-app1"]
}

