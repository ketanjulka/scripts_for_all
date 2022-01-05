provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "Office@365"
  vsphere_server = "vcsa.o365experts.local"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_datacenter" "Lab_DC" {
  name = "Lab_DC"
}

resource "vsphere_compute_cluster" "Cluster-Prod" {
  name          = "Cluster-Prod"
  datacenter_id = vsphere_datacenter.Lab_DC.moid
  drs_enabled   = false
  ha_enabled    = false
}

resource "vsphere_host" "Host1" {
  hostname = "10.50.15.21"
  username = "root"
  password = "Office@365"
  cluster = vsphere_compute_cluster.Cluster-Prod.id
}

resource "vsphere_host" "Host2" {
  hostname = "10.50.15.22"
  username = "root"
  password = "Office@365"
  cluster = vsphere_compute_cluster.Cluster-Prod.id
}