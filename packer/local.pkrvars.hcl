proxmox_url          = "https://127.0.0.1:8006/api2/json"
proxmox_username     = "root@pam!packer"  # API Token ID
proxmox_storage      = "local-lvm"
proxmox_storage_type = "lvm"
talos_version        = "v1.4.2"
static_ip            = "10.1.1.30/24" # static ip for vm to ssh
gateway              = "10.1.1.1" # gateway for vm to ssh