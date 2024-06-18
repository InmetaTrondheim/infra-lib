variable "location" {
  description = "The location where resources will be created."
  type        = string
}

variable "project_name" {
  description = "The name of the project to which resources are tied."
  type        = string
}

variable "environment" {
  description = "The environment for the resources."
  type        = string
}

variable "address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
}



