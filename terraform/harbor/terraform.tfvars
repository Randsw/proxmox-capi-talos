proxmox_host            = "https://10.10.10.1:8006/api2/json"
proxmox_token_id        = "root@pam!rand_terraform"
proxmox_storage1        = "local-zfs"              # proxmox storage lvm 1
proxmox_storage2        = "local-zfs"              # proxmox storage lvm 2
target_node_name        = "pve"
region                  = "CAPI"                    # proxmox cluster name
pool                    = "prod"                    # proxmox pool for vms
cache_registry_ip       = "10.10.10.201"
harbor_vmid             = "500"
gateway                 = "10.10.10.1"

