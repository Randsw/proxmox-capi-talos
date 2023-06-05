resource "proxmox_vm_qemu" "container-registry" {
  name        = "cache-registry"
  target_node = var.target_node_name
  clone       = var.proxmox_registry_image
  vmid        = var.harbor_vmid

  agent                   = 1
  define_connection_info  = false
  os_type                 = "cloud-init"
  qemu_os                 = "l26"
  ipconfig0               = "ip=${var.cache_registry_ip}/24,gw=${var.gateway}"
  ciuser     = "ubuntu"
  cipassword = "ubuntu"

  onboot  = false
  cpu     = "kvm64,flags=+aes"
  sockets = 1
  cores   = 4
  memory  = 8192
  scsihw  = "virtio-scsi-pci"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  boot = "order=scsi0"
  disk {
    slot    = 0
    type    = "scsi"
    storage = var.proxmox_storage2
    size    = "80G"
    cache   = "writethrough"
    ssd     = 1
    backup  = false
    #https://github.com/Telmate/terraform-provider-proxmox/issues/704
    file    = "vm-${var.harbor_vmid}-disk-0"
    volume  = "local-lvm:vm-${var.harbor_vmid}-disk-0"
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
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo '{\"insecure-registries\":[\"${var.cache_registry_ip}:5000\",\"0.0.0.0\"]}' | sudo tee /etc/docker/daemon.json",
      "sudo systemctl restart docker",
      "cd /home/ubuntu/harbor",
      "cp harbor.yml.tmpl harbor.yml",
      "sed -i 's/^hostname: .*/hostname: ${var.cache_registry_ip}/g' harbor.yml",
      "sed -i 's/^harbor_admin_password: .*/harbor_admin_password: ${var.harbor_admin_password}/g' harbor.yml",
      "sed -e '/port: 443/ s/^#*/#/' -i harbor.yml",
      "sed -e '/https:/ s/^#*/#/' -i harbor.yml",
      "sed -e '/certificate:*/ s/^#*/#/' -i harbor.yml",
      "sed -e '/prvate_key:*/ s/^#*/#/' -i harbor.yml",
      "sudo ./install.sh",
      "sleep 15s"
    ]    
    connection {
      type = "ssh"
      user = "ubuntu"
      password = "ubuntu"
      host = "${var.cache_registry_ip}"
    }
  }
}

# resource "null_resource" "example" {
#   provisioner "remote-exec" {
#     connection {
#       type = "ssh"
#       user = "ubuntu"
#       password = "ubuntu"
#       host = "${var.cache_registry_ip}"
#     }

#     inline = [
#       "echo '{\"insecure-registries\":[\"${var.cache_registry_ip}:5000\",\"0.0.0.0\"]}' | sudo tee /etc/docker/daemon.json",
#       "sudo systemctl restart docker",
#       "cd /home/ubuntu/harbor",
#       "cp harbor.yml.tmpl harbor.yml",
#       "sed -i 's/^hostname: .*/hostname: ${var.cache_registry_ip}/g' harbor.yml",
#       "sed -i 's/^harbor_admin_password: .*/harbor_admin_password: ${var.harbor_admin_password}/g' harbor.yml",
#       "sed -e '/port: 443/ s/^#*/#/' -i harbor.yml",
#       "sed -e '/https:/ s/^#*/#/' -i harbor.yml",
#       "sed -e '/certificate:*/ s/^#*/#/' -i harbor.yml",
#       "sed -e '/prvate_key:*/ s/^#*/#/' -i harbor.yml",
#       "sudo ./install.sh"
#     ]
#   }
# }