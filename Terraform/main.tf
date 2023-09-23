terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.73.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

variable "ssh_source_address" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "dns_zone" {
  type    = string
  default = "mydomain.com"
}

variable "resource_group" {
  type    = string
  default = "MyResourceGroup"
}

resource "azurerm_virtual_network" "my-vnet" {
  name                = "my-vnet"
  location            = "westus2"
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "my-internal" {
  name                 = "my-internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.my-vnet
  ]
}
