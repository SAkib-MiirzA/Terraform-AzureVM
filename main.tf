provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "Azure-Terraform"
  location = "East US"
}

# Storage account for state backend
resource "azurerm_storage_account" "example" {
  name                     = "terraform00786"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

# Storage container for state backend
resource "azurerm_storage_container" "example" {
  name                  = "terraform-state"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                  = "Terraform"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_DS1_v2"
  admin_username        = "AZure"
  network_interface_ids = [azurerm_network_interface.example.id]
  disable_password_authentication = false

  admin_password = "azure@123"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = ["source_image_reference"]
  }
}

# Virtual network
resource "azurerm_virtual_network" "example" {
  name                = "Terraform-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "Terraform-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network interface
resource "azurerm_network_interface" "example" {
  name                = "Terraform-nic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Public IP
resource "azurerm_public_ip" "example" {
  name                = "Terraform-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
