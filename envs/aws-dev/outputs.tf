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
