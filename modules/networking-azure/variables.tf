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

variable "vnet_cidr" {
  description = "CIDR block for the VNet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (must be inside vnet_cidr)"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR allowed to reach SSH and internal monitoring UIs"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid CIDR and cannot be 0.0.0.0/0 — use your own IP (x.x.x.x/32)."
  }
}
