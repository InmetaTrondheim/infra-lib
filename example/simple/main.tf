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
# uncomment once backend is created
#  backend "azurerm" {
#    resource_group_name   = "TerraformStateRG"
#    storage_account_name  = "tfstate${var.project_name}"
#    container_name        = "tfstate"
#    key                   = "core.terraform.tfstate"
#  }
  }
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

module "aca" {
  source = "../../modules/aca"
  core   = module.core
  name   = "aca"
  db     = module.pg-db
}

module "ingress" {
  source = "../../modules/ingress"
  core   = module.core
  name   = "ingress"
  target = module.aca
  url    = "aca"
}

