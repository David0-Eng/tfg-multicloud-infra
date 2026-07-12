output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.networking.app_security_group_id
}

output "instance_public_ip" {
  description = "Public IP of the application instance"
  value       = module.compute.public_ip
}

output "ssh_command" {
  description = "Ready-to-use SSH command"
  value       = "ssh -i ~/.ssh/tfg-dev-key.pem ubuntu@${module.compute.public_ip}"
}
