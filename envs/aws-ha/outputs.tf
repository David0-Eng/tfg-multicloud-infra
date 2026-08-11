output "alb_url" {
  description = "Public URL of the application through the load balancer"
  value       = "http://${module.loadbalancer.alb_dns_name}"
}

output "instance_a_public_ip" {
  description = "Public IP of instance A (AZ 1)"
  value       = module.compute_a.public_ip
}

output "instance_b_public_ip" {
  description = "Public IP of instance B (AZ 2)"
  value       = module.compute_b.public_ip
}

output "ssh_instance_a" {
  description = "SSH command for instance A"
  value       = "ssh -i ~/.ssh/tfg-dev-key.pem ubuntu@${module.compute_a.public_ip}"
}

output "ssh_instance_b" {
  description = "SSH command for instance B"
  value       = "ssh -i ~/.ssh/tfg-dev-key.pem ubuntu@${module.compute_b.public_ip}"
}
