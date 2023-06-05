# TF setup
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.14"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = "~> 3.9.1"
    }
  }
}