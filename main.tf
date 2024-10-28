terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.25.0"
    }
  }

  backend "azurerm" {
    subscription_id      = "40120347-0aa3-4761-a7ea-a1b9151412a4"
    resource_group_name  = "ArgoCD"
    storage_account_name = "mystatefileterraform"
    container_name       = "prod"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "40120347-0aa3-4761-a7ea-a1b9151412a4"
  client_id       = "29b51f5f-537b-41f3-ae43-fa2fb1cc83d6"
  client_secret   = "zT.8Q~x1Yaj0xRJijbsoO63PLRmpOQ7_TzoW5cKr"
  tenant_id       = "2d281bb5-1697-4054-99e8-8ad9ff83402b"
  features {}
}


# Resource group

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Allow All Traffic (Inbound & Outbound)
resource "azurerm_network_security_rule" "allow_all" {
  name                        = "allow_all_traffic"
  resource_group_name         = azurerm_resource_group.example.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "30-35"
  destination_port_range      = "30-35"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
}

# Public IP
resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# NIC for the VM
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id  # Associate public IP
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2_v3"

  admin_username = "hari"  # Use your username

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

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

  disable_password_authentication  = false
  admin_password = "Harikrishnan123#"  # Don't use hardcoded passwords in production
}

# Output the VM's public IP
output "vm_public_ip" {
  value = azurerm_public_ip.example.ip_address  # Fetch the public IP address
}
