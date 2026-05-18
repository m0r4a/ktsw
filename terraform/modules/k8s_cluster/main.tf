resource "proxmox_vm_qemu" "cloudinit" {
  for_each = local.nodes_normalized

  vmid        = each.value.vmid
  name        = each.value.hostname
  target_node = var.proxmox_node
  agent       = 1
  cpu {
    cores = each.value.cores
  }
  memory           = each.value.memory
  boot             = "order=scsi0"     # has to be the same as the OS disk of the template
  clone            = var.template_name # The name of the template
  scsihw           = "virtio-scsi-single"
  vm_state         = "running"
  automatic_reboot = true

  # Cloud-Init configuration
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # /var/lib/vz/snippets/qemu-guest-agent.yml
  ciupgrade  = true
  nameserver = "1.1.1.1 8.8.8.8"
  ipconfig0  = "ip=${each.value.ip}/${var.network_cidr},gw=${var.network_gateway}"
  skip_ipv6  = true
  ciuser     = var.vm_user
  cipassword = each.value.password
  sshkeys    = local.ssh_public_key_content

  # Most cloud-init images require a serial device for their display
  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
        disk {
          storage = "local-lvm"
          # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
          size = each.value.disk_size
        }
      }
    }
    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = var.network_bridge
    model  = "virtio"
  }
}

resource "null_resource" "ssh_keyscan" {
  for_each = local.nodes_normalized

  triggers = {
    vm_id = proxmox_vm_qemu.cloudinit[each.key].id
    vm_ip = each.value.ip
  }

  provisioner "local-exec" {
    command = <<EOT
      # Delete old key
      ssh-keygen -R ${each.value.ip} || true

      echo "Waiting for SSH to be ready on ${each.value.ip}..."

      for i in {1..10}; do
        KEY=$(ssh-keyscan -H ${each.value.ip} 2>/dev/null)

        # If key has something means it worked
        if [ -n "$KEY" ]; then
          echo "$KEY" >> ~/.ssh/known_hosts
          echo "SSH key succesfully added"
          exit 0
        fi

        echo "Attempt $i: SSH still not responding... retrying 10s"
        sleep 10
      done

      echo "Couldn't get the SSH key after many retries"
      exit 1
    EOT
  }

  depends_on = [proxmox_vm_qemu.cloudinit]
}
