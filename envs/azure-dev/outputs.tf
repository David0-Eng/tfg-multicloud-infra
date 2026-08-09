output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.networking.resource_group_name
}

output "vm_public_ip" {
  description = "Public IP of the application VM"
  value       = module.compute.public_ip
}

output "ssh_command" {
  description = "Ready-to-use SSH command"
  value       = "ssh -i ~/.ssh/tfg-dev-key.pem ${var.admin_username}@${module.compute.public_ip}"
}
