provider "azurerm" {
  features {}
}
# create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
# create virtual network 
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.Virtual_Machine_name[1]}-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# create subnet in vnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.Virtual_Machine_name[1]}-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#create Network interface 
resource "azurerm_network_interface" "Interface" {
  name                = "${var.Virtual_Machine_name[1]}-Nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.Virtual_Machine_name[1]}-IP"
    subnet_id                     = azurerm_subnet.subnet.id
    //private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.dc_ips[0]
  }
}

#create public ip address
resource "azurerm_public_ip" "public" {
  name                    = "${var.Virtual_Machine_name[1]}-PIP"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  
}

# create the  Vm machine 
resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.Virtual_Machine_name[1]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "vmadmin"
  admin_password      = "Welcome@1234"
  network_interface_ids = [
    azurerm_network_interface.Interface.id,
  ]
# Disk type define here
  os_disk {
    name = "${var.Virtual_Machine_name[1]}-OS-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
# os Source 
 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}