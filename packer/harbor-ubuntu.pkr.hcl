packer {
    required_plugins {
        proxmox = {
            version = " >= 1.1.0"
            source  = "github.com/hashicorp/proxmox"
        }
    }
}

# Resource Definiation for the VM Template
source "proxmox-iso" "harbor-ubuntu-jammy" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_url}"
    username = "${var.proxmox_username}"
    token = "${var.proxmox_token}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = proxmox_nodename
    vm_id = "999"
    template_name = "harbor-ubuntu"
    template_description = "Docker Ubuntu Server jammy Image"

    # VM OS Settings
    # (Option 1) Local ISO File
    iso_file = "local:iso/ubuntu-22.04.1-live-server-amd64.iso"
    unmount_iso = true

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        type              = "scsi"
        storage_pool      = var.proxmox_storage
        format            = "raw"
        disk_size         = "4000M"
        cache_mode        = "writethrough"
    }

    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "4096" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    boot_key_interval = "50ms"
    boot_wait = "6s"

    # PACKER Boot Commands from CD-ROM
    boot_command = [
        "c",
        "linux /casper/vmlinuz --- autoinstall ",
        "<enter><wait>",
        "initrd /casper/initrd<enter><wait>",
        "boot<enter>"
    ]
    
    additional_iso_files {
    cd_files = [
        "./http/meta-data",
        "./http/user-data"
    ]
    cd_label = "cidata"
    iso_storage_pool = "local"
    unmount = true
    }

    ssh_username = "ubuntu"
    ssh_password = "ubuntu"
    # Raise the timeout, when installation takes longer
    ssh_timeout = "60m"
}

# Build Definition to create the VM Template
build {

    name = "harbor-ubuntu-jammy"
    sources = ["source.proxmox-iso.harbor-ubuntu-jammy"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo cloud-init clean",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo sync",
            "sudo rm /etc/netplan/*.yaml",  # Remove network configuration created by subiquity
            "sudo rm /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg" #Enable network configuration using cloud-init 
        ]
    }
    
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
            "sudo apt-get install docker-compose-plugin",
            "sudo usermod -aG docker $USER"

        ]
    }

    provisioner "shell" {
        inline = [
            "curl https://github.com/goharbor/harbor/releases/download/v2.8.1/harbor-offline-installer-v2.8.1.tgz -o /home/ubuntu/harbor-offline-installer.tgz"
            "tar xzvf harbor-offline-installer.tgz"
        ]
    }


    # Delete CD-ROM with autoinstall cloud-init https://github.com/hashicorp/packer-plugin-proxmox/issues/83
    post-processor "shell-local" {
        command = "curl -k -X POST -H 'Authorization: PVEAPIToken=${var.proxmox_username}=${var.proxmox_token}' --data-urlencode delete=ide2 ${var.proxmox_url}/nodes/pve/qemu/999/config"
    }
    # Delete CD-ROM with ubuntu instalation ISO https://github.com/hashicorp/packer-plugin-proxmox/issues/83
    post-processor "shell-local" {
        command = "curl -k -X POST -H 'Authorization: PVEAPIToken=${var.proxmox_username}=${var.proxmox_token}' --data-urlencode delete=ide3 ${var.proxmox_url}/nodes/pve/qemu/999/config"
    }
    
}