data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  admin_cidr = var.admin_cidr != "" ? var.admin_cidr : "${chomp(data.http.my_ip.response_body)}/32"
}

module "networking" {
  source = "../../modules/networking-azure"

  project_name       = var.project_name
  environment        = var.environment
  location           = var.location
  vnet_cidr          = var.vnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
  admin_cidr         = local.admin_cidr
}

module "compute" {
  source = "../../modules/compute-azure"

  project_name        = var.project_name
  environment         = var.environment
  location            = module.networking.location
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.public_subnet_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_public_key    = var.admin_public_key
  stack_repo_url      = var.stack_repo_url
}
