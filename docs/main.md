# Azure Tenant Bootstrapping and Application Deployment with Terraform

This document outlines the process of bootstrapping a new Azure tenant and subsequently deploying an
application within that tenant using Terraform.

## Overview

The process consists of two main steps:
1. Bootstrapping the tenant
2. Deploying the application

Each step uses its own Terraform configuration but relies on state information from the previous
step.

## Prerequisites

- Terraform installed (version compatible with provider `azurerm ~>3.0`)
- Azure CLI installed and configured with appropriate credentials
- Access to Azure subscription with necessary permissions

## Normal Workflow

1. **Initial Setup (performed once per tenant)**
   - Run the tenant bootstrap Terraform configuration
   - Note the output values for backend state configuration
   - Update and reapply the tenant bootstrap configuration with backend state

2. **Application Deployment (performed for each new application and/or environment)**
   - Create the repo for the app deployment with the Terraform examle from
   - Configure the backend state using values from the tenant bootstrap
   - Apply the app deployment configuration

## Step 1: Bootstrapping the Tenant

### Configuration File: `example/tenant-bootstrap/main.tf`

This configuration sets up the core infrastructure for the tenant.
Create a repo in the tenant, this repo will be used for hosting the terraform
deffinition which describes the `tenant common` infrastructure.

Copy this file from the `tenant-bootstrap` directory to the repo created in the tenant.


### Usage

1. Navigate to the `tenant-bootstrap` repository you just created
2. Initialize Terraform: ``` terraform init ```
3. Modify input variables in the the main.tf file, or create a terraform.tfvars file with correct values
4. Apply the configuration: ``` terraform apply ```
5. Review the planned changes and type `yes` to proceed.
6. After successful application, note the output instructions for configuring the backend state.
7. Update the `main.tf` file, uncommenting and filling in the `backend "azurerm"` block with the
content of the output values from the `terraform apply`
8. Run the following commands to reconfigure Terraform to use the new backend: ``` terraform init
-migrate-state terraform apply ```

## Step 2: Deploying the Application

### Configuration File: `example/simple/main.tf`

This configuration deploys the application infrastructure and services.
Create a repo in the tenant, this repo will be used for hosting the terraform
deffinition which describes a `application` infrastructure

### Usage

1. Navigate to the `app` repository you just created
2. Update the `main.tf` file, uncommenting and filling in the `backend "azurerm"` block with the
values from the tenant bootstrap step: 
```hcl 
backend "azurerm" { 
  resource_group_name  = "bootstrap_resource_group_name"
  storage_account_name = "bootstrap_storage_account_name"
  container_name       = "bootstrap_container_name" 
  key                  = "app_state_file_key" 
} 
```
3. Initialize Terraform: ``` terraform init ```
4. Modify input variables in the the main.tf file, or create a terraform.tfvars file with correct values
5. Apply the configuration: ``` terraform apply ```
6. Review the planned changes and type `yes` to proceed.

