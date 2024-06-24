variable "tenant_name" {
  type    = string
  default = "common"
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
  #   resource_group_name  = # get value from output after running terraform apply
  #   storage_account_name = # get value from output after running terraform apply
  #   container_name       = # get value from output after running terraform apply
  #   key                  = # get value from output after running terraform apply
  # }

}

provider "azurerm" {
  features {}
}

module "tenant-core" {
  source             = "../../modules/company-core"
  tenant_name        = var.tenant_name
  location           = "North Europe"
  storage_containers = ["tfstate-${var.tenant_name}", "tfstate-app1"]
}

#print instructions about the next steps for using the state file
output "state_file_instructions" {
  value = <<EOF
  To use the state file, uncomment the backend block in main.tf and run terraform init.
  The block should look like this:
  ```
  backend "azurerm" {
      resource_group_name  = "${module.tenant-core.rg.name}"
      storage_account_name = "${module.tenant-core.storage_account.name}"
      container_name       = "tfstate-${var.tenant_name}"
      key                  = "${var.tenant_name}.terraform.tfstate"
  
  }
  ```

  Then run "terraform init -migrate-state" and "terraform apply".
  
  EOF
}
