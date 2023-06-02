resource "proxmox_vm_qemu" "controlplanes" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "cache-registry"
  target_node = var.target_node_name
  clone       = var.proxmox_registry_image

  agent                   = 0
  define_connection_info  = false
  os_type                 = "cloud-init"
  qemu_os                 = "l26"
  ipconfig0               = "ip=${cache_registry_ip}/24,gw=${var.gateway}"
  cloudinit_cdrom_storage = var.proxmox_storage2

  onboot  = false
  cpu     = "host,flags=+aes"
  sockets = 1
  cores   = 4
  memory  = 8192
  scsihw  = "virtio-scsi-pci"

  vga {
    memory = 0
    type   = "serial0"
  }
  serial {
    id   = 0
    type = "socket"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  boot = "order=scsi0"
  disk {
    type    = "scsi"
    storage = var.proxmox_storage2
    size    = "80G"
    cache   = "writethrough"
    ssd     = 1
    backup  = false
  }

  lifecycle {
    ignore_changes = [
      boot,
      network,
      desc,
      numa,
      agent,
      ipconfig0,
      ipconfig1,
      define_connection_info,
    ]
  }
}