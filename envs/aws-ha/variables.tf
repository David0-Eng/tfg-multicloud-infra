variable "aws_region" {
  description = "AWS region where all resources are created"
  type        = string
  default     = "eu-south-2" # Spain, matching Azure spaincentral
}

variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
  default     = "tfg"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "ha"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (distinct from aws-dev and azure-dev)"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Two subnets in two different AZs, required by the ALB"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
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
  default     = "https://github.com/David0-Eng/tfg-multicloud.git"
}

