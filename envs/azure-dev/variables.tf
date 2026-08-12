variable "subscription_id" {
  description = "Azure subscription ID (az account show --query id -o tsv)"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  # northeurope blocked by policy; spaincentral and francecentral have no
  # usable VM quota on the Students subscription
  default = "switzerlandnorth"
}

variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
  default     = "tfg"
}

variable "environment" {
  description = "Environment name (dev, prod, ...)"
  type        = string
  default     = "dev"
}

variable "vnet_cidr" {
  description = "CIDR block for the VNet (must not overlap the AWS VPC)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "admin_cidr" {
  description = "Optional override for the admin CIDR. Empty = auto-detect current public IP."
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "VM size"
  type        = string
  # 2 vCPU / 1 GiB, matching the AWS t3.micro for a fair comparison
  default = "Standard_B2ts_v2"
}

variable "admin_username" {
  description = "Admin user of the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_public_key" {
  description = "SSH public key line (ssh-keygen -y -f ~/.ssh/tfg-dev-key.pem)"
  type        = string
}

variable "stack_repo_url" {
  description = "Git URL of the Docker Compose stack. Empty = install Docker only."
  type        = string
  default     = "https://github.com/David0-Eng/tfg-multicloud.git"
}
