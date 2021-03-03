provider "azurerm" {
  subscription_id = "312b69f3-480b-46a3-afd6-ae7c053ab0ae"
  features {
  }
}

resource "azurerm_resource_group" "kul-rg" {
  name = "kul-rg"
  location = "East US"
}

# terraform init
# terraform validate
# terraform plan
# terraform apply
# terraform apply -auto-approve

resource "azurerm_virtual_network" "kul-vnet" {
  name = "kul-net"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.kul-rg.location
  resource_group_name = azurerm_resource_group.kul-rg.name
}

resource "azurerm_subnet" "default" {
  name = "default"
  address_prefixes = [ "10.0.1.0/24" ]
  virtual_network_name = azurerm_virtual_network.kul-vnet.name
  resource_group_name = azurerm_resource_group.kul-rg.name
}

resource "azurerm_public_ip" "kul-pip" {
  name = "kul-pip"
  location = azurerm_resource_group.kul-rg.location
  resource_group_name = azurerm_resource_group.kul-rg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "kul-nic" {
  name = "kul-nic"
  location = azurerm_resource_group.kul-rg.location
  resource_group_name = azurerm_resource_group.kul-rg.name
  ip_configuration {
    name = "ipconfig"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.kul-pip.id
  }
}

variable "admin_password" {
  description = "Enter the Admin Pwd to login to the VM"
  type = string
}

resource "azurerm_linux_virtual_machine" "kul-linux-vm" {
  name = "kul-linux-vm"
  location = azurerm_resource_group.kul-rg.location
  resource_group_name = azurerm_resource_group.kul-rg.name
  network_interface_ids = [ azurerm_network_interface.kul-nic.id ]
  size = "Standard_B1s"
  disable_password_authentication = false
  admin_username = "kmayer"
  admin_password = var.admin_password
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
    "Name" = "ManageByTerraform"
  }
}