variable "proxmox_node" {
  description = "The name of your proxmox node"
  type        = string
}

variable "template_name" {
  description = "The cloud-init's template name"
  type        = string
  default     = "rocky10-cloudinit"
}

variable "cluster_name" {
  description = "The prefix that the hostname of your VMs will have"
  type        = string
  default     = ""
}

variable "vm_user" {
  description = "The username of the main user for the image"
  type        = string
  default     = "root"
}

variable "vm_password" {
  description = "The password of the user defined on vm_user"
  type        = string
  default     = "terraform"
  sensitive   = true
}

variable "nodes" {
  description = "Declaration of your nodes"
  type = map(object({
    vmid      = number
    role      = string
    user      = optional(string)
    password  = optional(string)
    cores     = optional(number)
    memory    = optional(number)
    disk_size = optional(string)
    ip        = string
  }))

  validation {
    condition = alltrue([
      for node in var.nodes : contains(["control-plane", "worker"], node.role)
    ])
    error_message = "Role must be either control-plane or worker"
  }

  validation {
    condition     = length(var.nodes) == length(distinct([for node in var.nodes : node.vmid]))
    error_message = "All VMIDs must be unique across nodes"
  }

  validation {
    condition     = length([for node in var.nodes : node if node.role == "control-plane"]) >= 1
    error_message = "There must be at least one control-plane node"
  }
}

variable "cores" {
  description = "Amount of cores for your VMs"
  type        = number
  default     = 3

  validation {
    condition     = var.cores >= 2
    error_message = "Cores must be at least 2."
  }
}

variable "memory" {
  description = "Amount of RAM for your VMs (in MB)"
  type        = number
  default     = 4096

  validation {
    condition     = var.memory >= 2048
    error_message = "Memory must be at least 2048 MB (2 GB)."
  }
}

variable "disk_size" {
  description = "The size of the disk on the VM (e.g., 20G, 50G)"
  type        = string
  default     = "20G"

  validation {
    condition     = can(regex("^[0-9]+[GMgm]$", var.disk_size))
    error_message = "Disk size must be in format like '20G' or '20g' (number followed by G or M)."
  }

  validation {
    condition = (
      tonumber(regex("^([0-9]+)", var.disk_size)[0]) >= 20 &&
      can(regex("[Gg]$", var.disk_size))
      ) || (
      tonumber(regex("^([0-9]+)", var.disk_size)[0]) >= 20480 &&
      can(regex("[Mm]$", var.disk_size))
    )
    error_message = "Disk size must be at least 20G (or 20480M)."
  }
}

variable "ssh_user" {
  description = "The user you will ssh into"
  type        = string
  default     = "root"
}

variable "ssh_public_key" {
  description = "The .pub ssh key you want to add to the .authorized_keys. This key needs to match with your private key for Ansible."
  type        = string
}

variable "ssh_private_key_path" {
  description = "The path of the private key you will use with Ansible."
  type        = string

  validation {
    condition     = can(file(pathexpand(var.ssh_private_key_path)))
    error_message = "SSH private key file does not exist at the specified path."
  }

  validation {
    condition     = can(regex("^[~/.]", var.ssh_private_key_path))
    error_message = "SSH private key path must start with ~, /, or . (e.g., ~/.ssh/id_rsa or /home/user/.ssh/id_rsa)"
  }
}

variable "network_gateway" {
  description = "Your network gateway"
  type        = string
  default     = ""
}

variable "network_cidr" {
  description = "The cidr of your network"
  type        = number
  default     = 24
}

variable "network_bridge" {
  description = "The bridge that your VM will use"
  type        = string
  default     = "vmbr0"
}

variable "ansible_inventory_path" {
  description = "The path for your ansible inventory (directory only, filename will be added automatically)"
  type        = string
  default     = ""

  validation {
    condition     = var.ansible_inventory_path == "" || !can(regex("\\.(ini|yaml)$", var.ansible_inventory_path))
    error_message = "Path must not contain the filename. Provide only the directory path (e.g., './ansible' not './ansible/inventory.ini')."
  }
}
