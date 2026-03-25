# Proxmox Kubernetes Cluster Module

This Terraform module provisions virtual machines on Proxmox VE specifically designed for Kubernetes clusters. It handles Cloud-Init configurations, SSH key management, and automatically generates an Ansible inventory file compatible with the provisioned infrastructure.

## Prerequisites

Before running Terraform, your Proxmox node needs a dedicated API user, an API token, a cloud-init snippet, and a Rocky Linux 10 template. The included `proxmox-setup.sh` script automates all of this.

```bash
# Full setup (connects via SSH key)
./proxmox-setup.sh --host 192.168.1.10 --ssh-key ~/.ssh/id_ed25519

# Skip template creation if it already exists
./proxmox-setup.sh --host 192.168.1.10 --ssh-key ~/.ssh/id_ed25519 --skip-template --skip-snippet

# Tear everything down
./proxmox-setup.sh --host 192.168.1.10 --ssh-key ~/.ssh/id_ed25519 --uninstall
```

The script creates a `TerraformProv` role with the minimum required privileges, a `terraform-prov@pve` user, an API token, a `qemu-guest-agent` cloud-init snippet, and a `rocky10-cloudinit` VM template. At the end it prints the provider block and the `.env` exports you need.

## Usage
```hcl
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
```

## Requirements

| Name | Version |
| --- | --- |
| proxmox | 3.0.2-rc07 |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `proxmox_node` | The name of the target Proxmox node. | `string` | n/a | yes |
| `nodes` | Map of node definitions. See [Node Definitions](#node-definitions) below. | `map(object)` | n/a | yes |
| `ssh_public_key` | Raw public key content for `authorized_keys`. | `string` | n/a | yes |
| `ssh_private_key_path` | Path to the private key used for Ansible connectivity. | `string` | n/a | yes |
| `cluster_name` | Optional prefix for hostnames. | `string` | `""` | no |
| `vm_user` | Cloud-init username for the VM image. | `string` | `"root"` | no |
| `vm_password` | Password for `vm_user`. | `string` | `"terraform"` | no |
| `ssh_user` | User for SSH connections. | `string` | `"root"` | no |
| `cores` | Global default CPU cores (min 2). | `number` | `3` | no |
| `memory` | Global default RAM in MB (min 2048). | `number` | `4096` | no |
| `disk_size` | Global default disk size (min 20G). | `string` | `"20G"` | no |
| `template_name` | Name of the cloud-init template on Proxmox. | `string` | `"rocky10-cloudinit"` | no |
| `network_bridge` | Proxmox bridge the VMs will attach to. | `string` | `"vmbr0"` | no |
| `network_gateway` | Network gateway for the VMs. | `string` | `""` | no |
| `network_cidr` | Network prefix length. | `number` | `24` | no |
| `k3s_cluster_cidr` | Pod CIDR for the k3s cluster. | `string` | `"11.0.0.0/16"` | no |
| `k3s_service_cidr` | Service CIDR for the k3s cluster. | `string` | `"11.1.0.0/16"` | no |
| `ansible` | Ansible integration config. Set `enabled = true` to generate inventory and `group_vars`. Requires `path` when enabled. | `object({ enabled = bool, path = optional(string) })` | `{ enabled = false, path = "" }` | no |

## Outputs

This module currently has no outputs.

## Configuration Details

### Node Definitions

The `nodes` input is a map where the map key becomes the hostname (or suffix if `cluster_name` is set) and the value is an object defining the VM properties.

**Required Fields:**

* `vmid`: A unique integer ID for the Proxmox VM.
* `role`: Must be either `"control-plane"` or `"worker"`.
* `ip`: The static IP address for the VM.

**Optional Fields (Overrides):**

The following fields are optional. If omitted, the VM will inherit the global default value defined in the module variables (e.g., `var.cores`, `var.memory`).

* `cores`: Number of CPU cores.
* `memory`: RAM in MB.
* `disk_size`: Disk size (e.g., "20G").
* `user`: Cloud-init username.
* `password`: Cloud-init password.

**Validations:**

* At least one node must have `role = "control-plane"`.
* All `vmid` values must be unique.
* `cores` ≥ 2, `memory` ≥ 2048 MB, `disk_size` ≥ 20G.

### Ansible Integration

This module can generate an Ansible inventory file and `group_vars` based on the provisioned infrastructure.

* **Configuration:** Pass an `ansible` object with `enabled = true` and a `path` pointing to your Ansible directory.
* **Format:** The inventory groups nodes into `[control-plane]` and `[worker]` based on the role assigned in the `nodes` map.
* **SSH Access:** It configures `ansible_ssh_private_key_file` pointing to the path specified in `ssh_private_key_path`.
