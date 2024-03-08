packer {
  required_plugins {
    proxmox = {
      version = " >= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
      }
    }
}


source "proxmox-iso" "talos" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.proxmox_nodename
  insecure_skip_tls_verify = true
  vm_id = "598"

  iso_file    = "local:iso/archlinux-2023.04.01-x86_64.iso"
  unmount_iso = true

  scsi_controller = "virtio-scsi-pci"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    type              = "scsi"
    storage_pool      = var.proxmox_storage
    format            = "raw"
    disk_size         = "1500M"
    cache_mode        = "writethrough"
  }

  memory       = 2048
  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "15m"
  ssh_host     = var.static_ip
  qemu_agent   = false

  template_name        = "talos-${var.talos_version}"
  template_description = "Talos system disk"

  boot_key_interval = "50ms"
  boot_wait = "6s"

  boot_command = [
    "<enter><wait1m>",
    "systemctl stop dhcpcd<enter><wait>",
    "ip route flush 0/0<enter><wait>",
    "passwd<enter><wait>packer<enter><wait>packer<enter>",
    "ip addr flush dev ens18<enter><wait>",
    "ip address add ${var.static_ip}/24 broadcast + dev ens18<enter><wait>",
    "ip route add 0.0.0.0/0 via ${var.gateway} dev ens18<enter><wait>"
  ]
}

build {
  name    = "release"
  sources = ["source.proxmox-iso.talos"]

  provisioner "shell" {
    inline = [
      "curl -L ${local.image} -o /tmp/talos.raw.xz",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}

build {
  name    = "develop"
  sources = ["source.proxmox-iso.talos"]

  provisioner "file" {
    source      = "iso/nocloud-amd64.raw.xz"
    destination = "/tmp/talos.raw.xz"
  }
  provisioner "shell" {
    inline = [
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}