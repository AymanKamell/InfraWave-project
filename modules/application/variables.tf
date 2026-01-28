# modules/application/variables.tf

# Backend application port (must match networking module)
#variable "app_port" {
 # description = "Backend API port (e.g., 3000, 8080)"
 # type        = number
 # default     = 3000
#}

# Optional: Override default instance types
#variable "frontend_instance_type" {
 # description = "Frontend EC2 instance type"
  #type        = string
  #default     = "t3.micro"
#}

#variable "backend_instance_type" {
 # description = "Backend EC2 instance type"
 # type        = string
  #default     = "t3.micro"
#}

#variable "rds_instance_class" {
 # description = "RDS instance class"
  #type        = string
  #default     = "db.t3.micro"
#}


# modules/application/variables.tf
variable "app_port" {
  type = number
}

# Networking resource IDs (passed from root module)
variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "frontend_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

variable "rds_sg_id" {
  type = string
}

variable "bastion_sg_id" {
  type = string
}
