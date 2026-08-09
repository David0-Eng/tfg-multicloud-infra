variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, ...)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the VM is created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the NIC is placed"
  type        = string
}

variable "vm_size" {
  description = "VM size"
  type        = string
}

variable "admin_username" {
  description = "Admin user of the VM"
  type        = string
}

variable "admin_public_key" {
  description = "SSH public key line for the admin user"
  type        = string
}

variable "os_disk_gb" {
  description = "OS disk size in GiB"
  type        = number
  default     = 30
}

variable "stack_repo_url" {
  description = "Git URL of the Docker Compose stack. Empty = install Docker only."
  type        = string
  default     = ""
}
