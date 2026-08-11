variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, ha, ...)"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the load balancer lives"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnets for the ALB (minimum two, in different AZs)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An Application Load Balancer requires at least two subnets in different AZs."
  }
}

variable "app_security_group_id" {
  description = "Security group of the application instances (receives an ALB-only ingress rule)"
  type        = string
}

variable "instance_ids" {
  description = "Instances to register as targets"
  type        = list(string)
}

variable "app_port" {
  description = "Port where the application listens on the instances"
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "HTTP path used by the ALB health check"
  type        = string
  default     = "/health"
}
