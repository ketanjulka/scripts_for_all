# Creates the Data Center in VCSA.
resource "vsphere_datacenter" "Lab_DC" {
  name = "Lab_DC"
}

# Creates a Cluster in the above DC.
resource "vsphere_compute_cluster" "Cluster-Prod" {
  name          = "Cluster-Prod"
  datacenter_id = vsphere_datacenter.Lab_DC.moid
  drs_enabled   = false
  ha_enabled    = true
}

# Adds ESXi-01 and ESXi-02 to the cluster.
resource "vsphere_host" "Host1" {
  hostname   = "10.50.15.21"
  username   = var.ESXi_username
  password   = var.vcsa_password
  thumbprint = "D0:7C:5D:25:0C:E4:E7:5B:6A:27:F1:59:D7:DA:AE:96:84:02:0A:3D"
  cluster    = vsphere_compute_cluster.Cluster-Prod.id
}

resource "vsphere_host" "Host2" {
  hostname   = "10.50.15.22"
  username   = var.ESXi_username
  password   = var.ESXi_password
  thumbprint = "91:89:26:B8:0D:E9:80:C7:0B:68:BF:9D:11:C0:5C:0C:CB:46:1C:A7"
  cluster    = vsphere_compute_cluster.Cluster-Prod.id
}

    resource "time_sleep" "wait_for_ingress_alb" {
  create_duration = "30s"
}

resource "vsphere_distributed_virtual_switch" "vds" {
  name            = "Prod-VDS"
  datacenter_id   = vsphere_datacenter.Lab_DC.moid
  uplinks         = ["uplink1", "uplink2"]
  active_uplinks  = ["uplink1"]
  standby_uplinks = ["uplink2"]

  host {
    host_system_id = vsphere_host.Host1.id
    devices        = ["vmnic0"]
  }

  host {
    host_system_id = vsphere_host.Host2.id
    devices        = ["vmnic0"]
  }

}