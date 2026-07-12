variable "aws_region" {
  description = "AWS region where all resources are created"
  type        = string
  default     = "eu-west-1"
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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "admin_cidr" {
  description = "Optional override for the admin CIDR. Empty = auto-detect current public IP."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair for SSH"
  type        = string
  default     = "tfg-dev-key"
}

variable "stack_repo_url" {
  description = "Git URL of the Docker Compose stack. Empty = install Docker only."
  type        = string
  default     = ""
}
