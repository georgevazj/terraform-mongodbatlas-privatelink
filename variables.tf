# Azure dependencies
variable "resource_group_name" {
  type = string
  description = "(Required) Target Azure resource group"
}

variable "vnet_name" {
  type = string
  description = "(Required) Azure virtual network name"
}

variable "subnet_name" {
  type = string
  description = "(Required) Azure subnet name"
}

variable "region" {
  type = string
  description = "(Optional) Azure region. Default: westeurope"
  default = "westeurope"
}

# MongoDB Atlas variables
variable "project_id" {
  type = string
  description = "(Required) MongoDB Atlas project id"
}

variable "azure_pve_name" {
  type = string
  description = "(Required) Azure private endpoint name"
}

variable "cloud_name" {
  type = string
  description = "(Required) Cloud Provider name"
  default = "AZURE"
}