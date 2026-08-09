output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.app.id
}

output "public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.app.ip_address
}

output "private_ip" {
  description = "Private IP of the VM"
  value       = azurerm_network_interface.app.private_ip_address
}
