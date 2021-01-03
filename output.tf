# output public ip address 
data "azurerm_public_ip" "outpublicip" {
  name                = azurerm_public_ip.public.name
  resource_group_name = azurerm_windows_virtual_machine.vm.resource_group_name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.outpublicip.ip_address
}