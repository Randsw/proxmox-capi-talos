resource "proxmox_vm_qemu" "workers" {
  count       = 3
  name        = "mgmt-worker-${count.index}"
  target_node = var.target_node_name_worker
  clone       = join("-",[var.proxmox_image,var.talos_version])
  vmid        = var.worker_vmid +  count.index

  agent                   = 0
  define_connection_info  = false
  os_type                 = "cloud-init"
  qemu_os                 = "l26"
  ipconfig0               = "ip=${cidrhost(var.vpc_main_cidr, var.worker_first_ip + "${count.index}")}/24,gw=${var.gateway}"
  cloudinit_cdrom_storage = var.proxmox_storage1

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
    storage = var.proxmox_storage1
    size    = "30G"
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