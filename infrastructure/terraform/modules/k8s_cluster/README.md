## Usage

```hcl
module "k3s_cluster" {
  source = "./modules/k8s_cluster/"

  proxmox_node         = "server01"
  vm_user              = "my_user"
  vm_password          = "very_secure_password"
  ssh_private_key_path = "~/.ssh/id_ed25519"
  ssh_public_key       = "~/.ssh/id_ed25519.pub"

  nodes = {
    control-plane = {
      vmid = 201
      user = k8s_master
      role = "control-plane"
      ip   = "10.0.0.7"
    }
    worker = {
      vmid   = 202
      role   = "worker"
      memory = 8192
      cores  = 5
      ip     = "10.0.0.8"
    }
  }

  network_bridge  = "vmbr1"
  network_gateway = "10.0.0.254"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.2-rc07 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.2-rc07 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.ssh_keyscan](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [proxmox_vm_qemu.cloudinit](https://registry.terraform.io/providers/telmate/proxmox/3.0.2-rc07/docs/resources/vm_qemu) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_inventory_path"></a> [ansible\_inventory\_path](#input\_ansible\_inventory\_path) | The path for your ansible inventory (directory only, filename will be added automatically) | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The prefix that the hostname of your VMs will have | `string` | `""` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Amount of cores for your VMs | `number` | `3` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The size of the disk on the VM (e.g., 20G, 50G) | `string` | `"20G"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of RAM for your VMs (in MB) | `number` | `4096` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | The bridge that your VM will use | `string` | `"vmbr0"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | The cidr of your network | `number` | `24` | no |
| <a name="input_network_gateway"></a> [network\_gateway](#input\_network\_gateway) | Your network gateway | `string` | `""` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Declaration of your nodes | <pre>map(object({<br/>    vmid       = number<br/>    role       = string<br/>    ciuser     = optional(string)<br/>    cipassword = optional(string)<br/>    cores      = optional(number)<br/>    memory     = optional(number)<br/>    disk_size  = optional(string)<br/>    ip         = string<br/>  }))</pre> | n/a | yes |
| <a name="input_proxmox_node"></a> [proxmox\_node](#input\_proxmox\_node) | The name of your proxmox node | `string` | n/a | yes |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | The path of the private key you will use with Ansible. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The .pub ssh key you want to add to the .authorized\_keys. This key needs to match with your private key for Ansible. | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | The user you will ssh into | `string` | `"root"` | no |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | The cloud-init's template name | `string` | `"rocky10-cloudinit"` | no |
| <a name="input_vm_password"></a> [vm\_password](#input\_vm\_password) | The password of the user defined on vm\_user | `string` | `"terraform"` | no |
| <a name="input_vm_user"></a> [vm\_user](#input\_vm\_user) | The username of the main user for the image | `string` | `"root"` | no |

## Outputs

No outputs.
