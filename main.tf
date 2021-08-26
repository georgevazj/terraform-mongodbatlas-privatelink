terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.0.0"
    }
  }
}

# Configure the MongoDB Atlas provider
provider "azurerm" {
  features {}
}

provider "mongodbatlas" {
}

# Query data from Azure
data "azurerm_resource_group" "rsg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rsg.name
}

data "azurerm_subnet" "subnet" {
  name = var.subnet_name
  resource_group_name = data.azurerm_resource_group.rsg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

# MongoDB Atlas resources
resource "mongodbatlas_privatelink_endpoint" "mongo_pve" {
  project_id = var.project_id
  provider_name = var.cloud_name
  region = var.region
}

resource "azurerm_private_endpoint" "azure_pve" {
  location = data.azurerm_resource_group.rsg.location
  name = var.azure_pve_name
  resource_group_name = data.azurerm_resource_group.rsg.name
  subnet_id = data.azurerm_subnet.subnet.id

  private_service_connection {
    is_manual_connection = true
    name = mongodbatlas_privatelink_endpoint.mongo_pve.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.mongo_pve.private_link_service_resource_id
    request_message = "Azure Private Link"
  }
}

resource "mongodbatlas_privatelink_endpoint_service" "mongo_pve_service" {
  project_id = var.project_id
  private_link_id = mongodbatlas_privatelink_endpoint.mongo_pve.private_link_id
  endpoint_service_id = azurerm_private_endpoint.azure_pve.id
  private_endpoint_ip_address = azurerm_private_endpoint.azure_pve.private_service_connection.0.private_ip_address
  provider_name = var.cloud_name
}