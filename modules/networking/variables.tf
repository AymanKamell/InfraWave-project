variable "admin_ip" {
  description = "Administrator's public IP for SSH access"
  type        = string
}

variable "app_port" {
  description = "Backend application port (e.g., 3000, 8080)"
  type        = number
  default     = 3000
}