variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, ...)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the instance is launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group attached to the instance"
  type        = string
}

variable "root_volume_gb" {
  description = "Root disk size in GiB"
  type        = number
  default     = 30
}

variable "stack_repo_url" {
  description = "Git URL of the Docker Compose stack. Empty = install Docker only."
  type        = string
  default     = ""
}

variable "discord_webhook_param" {
  description = "Name of the SSM parameter holding the Discord webhook URL. Empty = skip secret injection."
  type        = string
  default     = ""
}
