variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, ...)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per AZ (must be inside vpc_cidr)"
  type        = list(string)
}

variable "expose_app_public" {
  description = "Expose the app port (8000) to the internet. Set false when traffic must enter through a load balancer."
  type        = bool
  default     = true
}

variable "restrict_egress" {
  description = "Restrict outbound traffic to HTTP/HTTPS, DNS and NTP instead of allowing everything."
  type        = bool
  default     = false
}

variable "admin_cidr" {
  description = "CIDR allowed to reach SSH and internal monitoring UIs (your IP, x.x.x.x/32)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid CIDR and cannot be 0.0.0.0/0 — use your own IP (x.x.x.x/32)."
  }
}

