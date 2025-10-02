terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc4"
    }
    ansible = {
        source = "nbering/ansible"
        version = "1.0.4"
    }
  }
  backend "s3" {
      bucket = "jackbazbackend"
      key    = "tests/integration/proxmox.tfstate"
      region               = "eu-west-1"
  }

}

provider "proxmox" {
  pm_api_url = "https://pve-wolfe.tailae395a.ts.net:8006/api2/json"
  pm_tls_insecure = true
  pm_user = "terraform@pve"
  # pm_password = var.pm_password
}

resource "proxmox_vm_qemu" "cloudinit-example" {
  vmid        = 100
  name        = "test-terraform0"
  target_node = "pve"
  agent       = 1
  cores       = 2
  memory      = 1024
  boot        = "order=scsi0" # has to be the same as the OS disk of the template
  clone       = "debian-12-cloud" # The name of the template
  scsihw      = "virtio-scsi-single"
  vm_state    = "running"
  automatic_reboot = true

  # Cloud-Init configuration
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # /var/lib/vz/snippets/qemu-guest-agent.yml
  ciupgrade  = true
  nameserver = "1.1.1.1 8.8.8.8"
  ipconfig0  = "ip=192.168.1.10/24,gw=192.168.1.1,ip6=dhcp"
  skip_ipv6  = true
  ciuser     = "root"
  cipassword = "Enter123!"
  # sshkeys    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/Pjg7YXZ8Yau9heCc4YWxFlzhThnI+IhUx2hLJRxYE Cloud-Init@Terraform"

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
          size    = "32G" 
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
    id = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
}
