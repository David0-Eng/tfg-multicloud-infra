# Detect the operator's current public IP at plan time.
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  # Manual override via var.admin_cidr wins; otherwise use the detected IP.
  admin_cidr = var.admin_cidr != "" ? var.admin_cidr : "${chomp(data.http.my_ip.response_body)}/32"
}

module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  admin_cidr         = local.admin_cidr
}
