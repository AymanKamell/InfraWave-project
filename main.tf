# main.tf (root)
module "networking" {
  source   = "./modules/networking"
  admin_ip = "203.0.113.42/32" # ← REPLACE WITH YOUR ACTUAL IP
  app_port = 3000
}
