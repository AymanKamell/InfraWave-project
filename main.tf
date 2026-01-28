# main.tf (ROOT MODULE - project root)
# Compose networking + application layers

module "networking" {
  source   = "./modules/networking"
  admin_ip = var.admin_ip # ← PASS FROM ROOT VARIABLES (not hardcoded!)
  app_port = var.app_port
}

module "application" {
  source = "./modules/application"

  # Pass application-specific variables
  app_port = var.app_port

  # CRITICAL: Pass networking resources via module outputs
  # (These outputs MUST exist in modules/networking/outputs.tf)
  vpc_id            = module.networking.vpc_id
  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  frontend_sg_id    = module.networking.frontend_sg_id
  backend_sg_id     = module.networking.backend_sg_id
  rds_sg_id         = module.networking.rds_sg_id
  bastion_sg_id     = module.networking.bastion_sg_id # Optional if bastion exists
}
