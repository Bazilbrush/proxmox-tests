terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
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
  pm_tls_unsecure = true
  pm_user = "root@pam"
  pm_password = var.pm_password
}