# provider "proxmox" {
#   pm_api_url      = "https://192.168.1.2:8006/api2/json"
#   pm_tls_insecure = true
# }
#
# terraform {
#   required_providers {
#     proxmox = {
#       source  = "telmate/proxmox"
#       version = "3.0.2-rc07"
#     }
#   }
# }
#
# module "k3s_cluster" {
#   source = "./modules/k8s_cluster/"
#
#   proxmox_node         = "server01"
#   vm_user              = "my_user"
#   vm_password          = "very_secure_password"
#   ssh_private_key_path = "~/.ssh/id_ed25519"
#   ssh_public_key       = "~/.ssh/id_ed25519.pub"
#
#   nodes = {
#     control-plane = {
#       vmid = 201
#       user = k8s_master
#       role = "control-plane"
#       ip   = "10.0.0.7"
#     }
#     worker = {
#       vmid   = 202
#       role   = "worker"
#       memory = 8192
#       cores  = 5
#       ip     = "10.0.0.8"
#     }
#   }
#
#   network_bridge  = "vmbr1"
#   network_gateway = "10.0.0.254"
# }
