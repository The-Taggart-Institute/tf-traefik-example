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
  default = "whisper"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "dns_zone" {
  type    = string
  default = "whisperwolf.net"
}

variable "resource_group" {
  type    = string
  default = "Training"
}

resource "azurerm_virtual_network" "whisperwolf-vnet" {
  name                = "whisperwolf-vnet"
  location            = "westus2"
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "whisperwolf-internal" {
  name                 = "whisperwolf-internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.whisperwolf-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.whisperwolf-vnet
  ]
}
