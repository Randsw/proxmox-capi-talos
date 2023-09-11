proxmox_host            = "https://10.1.1.1:8006/api2/json"
proxmox_token_id        = "root@pam!terraform"
proxmox_storage1        = "local-lvm"              # proxmox storage lvm 1
proxmox_storage2        = "local-lvm"              # proxmox storage lvm 2
target_node_name        = "proxmox"
region                  = "CAPI"                    # proxmox cluster name
pool                    = "prod"                    # proxmox pool for vms
cache_registry_ip       = "10.1.1.151"

