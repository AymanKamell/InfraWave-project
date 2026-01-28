variable "admin_ip" {
  description = "Your public IP address (CIDR format)"
  type        = string
}

variable "app_port" {
  description = "Backend API port"
  type        = number
  default     = 3000
}
