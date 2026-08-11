data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  admin_cidr = var.admin_cidr != "" ? var.admin_cidr : "${chomp(data.http.my_ip.response_body)}/32"
}

module "networking" {
  source = "../../modules/networking"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  admin_cidr          = local.admin_cidr

  # Instances are not reachable on the app port from the internet;
  # traffic must enter through the ALB.
  expose_app_public = false
}

module "compute_a" {
  source = "../../modules/compute"

  project_name      = var.project_name
  environment       = "${var.environment}-a"
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.networking.app_security_group_id
  stack_repo_url    = var.stack_repo_url
}

module "compute_b" {
  source = "../../modules/compute"

  project_name      = var.project_name
  environment       = "${var.environment}-b"
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.networking.public_subnet_ids[1]
  security_group_id = module.networking.app_security_group_id
  stack_repo_url    = var.stack_repo_url
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.public_subnet_ids
  app_security_group_id = module.networking.app_security_group_id
  instance_ids          = [module.compute_a.instance_id, module.compute_b.instance_id]
}
