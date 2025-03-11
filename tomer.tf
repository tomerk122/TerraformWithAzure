# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "3f79a68d-cf0d-4291-a31f-185897f7fda1"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "Tomer-terraform-rg"
  location = "East US" # Change to your preferred region
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "Tomer-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "Tomer-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "Tomer-my-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic" # Explicitly use Basic SKU
}

# Create a network security group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "Tomer-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "Tomer-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Tomer-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Define your SSH public key
variable "ssh_public_key" {
  default = "~/.ssh/azure_key.pub" # Path to your public key
}

# Create a small Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "TomerK-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s" # Small instance size

  os_disk {
    name                 = "Tomer-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key)
  }

  disable_password_authentication = true
}
#ssh -i ~/.ssh/azure_key azureuser@40.117.76.50
# we assume that the public key is in the same directory as the terraform file
# for creating the key pair use the following command
# ssh-keygen -t rsa -b 2048 -f ~/.ssh/azure_key -C azureuser

