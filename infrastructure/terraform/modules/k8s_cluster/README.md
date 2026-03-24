# Proxmox Kubernetes Cluster Module

# TODO: Update this.

This Terraform module provisions virtual machines on Proxmox VE specifically designed for Kubernetes clusters. It handles Cloud-Init configurations, SSH key management, and automatically generates an Ansible inventory file compatible with the provisioned infrastructure.

## Usage

```hcl
module "k3s_cluster" {
  source = "./modules/k8s_cluster/"

  # Connection to Proxmox
  proxmox_node         = "pve-01"

  # Global Default Settings (applied if not defined at node level)
  vm_user              = "ops_user"
  vm_password          = "secure_password"
  ssh_private_key_path = "~/.ssh/id_ed25519"
  ssh_public_key       = "~/.ssh/id_ed25519.pub"

  # Network defaults
  network_bridge       = "vmbr1"
  network_gateway      = "10.0.0.1"
  network_cidr         = 24

  # Ansible configs
  ansible = {
    enabled = true
    path    = "../ansible"
  }

  # Node Definitions
  nodes = {
    # Hostname will be: control-plane-01
    "control-plane-01" = {
      vmid = 201
      role = "control-plane"
      ip   = "10.0.0.10"
    }

    # Hostname will be: worker-high-mem
    "worker-high-mem" = {
      vmid      = 202
      role      = "worker"
      ip        = "10.0.0.20"
      # Overriding global defaults
      memory    = 16384 
      cores     = 8
      disk_size = "50G"
    }
  }
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
| `ssh_public_key` | Path to public key or raw public key content for `authorized_keys`. | `string` | n/a | yes |
| `ssh_private_key_path` | Path to the private key used for Ansible connectivity. | `string` | n/a | yes |
| `cluster_name` | Optional prefix for hostnames. | `string` | `""` | no |
| `cores` | Global default CPU cores. | `number` | `3` | no |
| `memory` | Global default RAM (MB). | `number` | `4096` | no |
| `disk_size` | Global default disk size. | `string` | `"20G"` | no |
| `template_name` | Name of the cloud-init template on Proxmox. | `string` | `"rocky10-cloudinit"` | no |
| `ansible_inventory_path` | Directory path for the generated inventory file. | `string` | `""` | no |

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

### Ansible Integration

This module can generate an Ansible inventory file and group_vars based on the provisioned infrastructure.

* **Location:** By default, the file is created at `../ansible/inventory.ini`. You can customize the directory using the `ansible_inventory_path` variable.
* **Format:** The inventory groups nodes into `[control-plane]` and `[worker]` based on the role assigned in the `nodes` map.
* **SSH Access:** It configures the `ansible_ssh_private_key_file` variable pointing to the path specified in `ssh_private_key_path`.
