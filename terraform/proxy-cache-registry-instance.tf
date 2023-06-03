resource "proxmox_vm_qemu" "container-registry" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "cache-registry"
  target_node = var.target_node_name
  clone       = var.proxmox_registry_image

  agent                   = 0
  define_connection_info  = false
  os_type                 = "cloud-init"
  qemu_os                 = "l26"
  ipconfig0               = "ip=${var.cache_registry_ip}/24,gw=${var.gateway}"
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
  provisioner "remote-exec" {
    inline = [
      "sudo echo '{\"insecure-registries\":[\"${var.cache_registry_ip}:5000\",\"0.0.0.0\"]}' > /etc/docker/daemon.json",
      "sudo systemctl restart docker",
      "cd /home/ubuntu",
      "sed -i 's/^hostname: .*/hostname ${var.cache_registry_ip}/g' harbor.yml.tmpl",
      "sed -i 's/^harbor_admin_password: .*/harbor_admin_password ${var.harbor_admin_password}/g' harbor.yml.tmpl",
      "cp harbor.yml.tmpl harbor.yaml",
      "sudo ./install.sh"
    ]    
    connection {
    type = "ssh"
    user = "ubuntu"
    password = "ubuntu"
    host = "${var.cache_registry_ip}"
    
    }
  }
}