provider "vsphere" {
  user           = var.vcsa_username
  password       = var.vcsa_password
  vsphere_server = "vcsa.o365experts.local"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}