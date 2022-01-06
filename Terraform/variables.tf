# VCSA Admin credentials.
variable "vcsa_username" {
  description = "VCSA administrator username"
  type        = string
  sensitive   = true
}
variable "vcsa_password" {
  description = "VCSA administrator password"
  type        = string
  sensitive   = true
}

# ESXi root credentials.
variable "ESXi_username" {
  description = "ESXi root username"
  type        = string
  sensitive   = true
}

variable "ESXi_password" {
  description = "ESXi root password"
  type        = string
  sensitive   = true
}