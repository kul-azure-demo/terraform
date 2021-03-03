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
