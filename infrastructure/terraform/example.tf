provider "proxmox" {
  pm_api_url      = "https://192.168.1.2:8006/api2/json"
  pm_tls_insecure = true
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

module "k3s_cluster" {
  source = "./modules/k8s_cluster/"

  proxmox_node         = "server01"
  vm_user              = "user"
  vm_password          = "mysuperpassword"
  ssh_private_key_path = "~/.ssh/id_ed25519"
  ssh_public_key       = "~/.ssh/id_ed25519.pub"

  ansible = {
    enabled = true
    path    = "../ansible"
  }

  nodes = {
    control-plane = {
      vmid   = 201
      role   = "control-plane"
      ip     = "10.0.0.10"
      memory = 4096
      cores  = 4
    }
    worker1 = {
      vmid   = 202
      role   = "worker"
      ip     = "10.0.0.11"
      memory = 4096
      cores  = 3
    }

  network_bridge  = "vmbr1"
  network_gateway = "10.0.0.253"
}
