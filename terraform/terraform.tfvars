vpc_main_cidr           = "10.10.10.0/24"            # nodes subnet
gateway                 = "10.10.10.1"               # subnet gateway
first_ip                = "105"                      # first ip address of the master-1 node - 10.10.10.105
worker_first_ip         = "108"                      # first ip address of the worker-1 node - 10.10.10.108
proxmox_host            = "https://10.10.10.1:8006/api2/json"
proxmox_token_id        = "root@pam!rand_terraform"
proxmox_storage1        = "local-zfs"              # proxmox storage lvm 1
proxmox_storage2        = "local-zfs"              # proxmox storage lvm 2
target_node_name        = "pve"
target_node_name_worker = "pve"
k8s_version             = "v1.27.2"                # k8s version
proxmox_image           = "talos"                  # talos image created by packer
talos_version           = "v1.4.5"                   # talos version for machineconfig gen
cluster_endpoint        = "https://10.10.10.200:6443" # cluster endpoint to fetch via talosctl
region                  = "CAPI"                    # proxmox cluster name
pool                    = "prod"                    # proxmox pool for vms
private_key_file_path   = "~/.ssh/id_ed25519"          # fluxcd git creds for ssh
public_key_file_path    = "~/.ssh/id_ed25519.pub"      # fluxcd git creds for ssh
known_hosts             = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="

kubernetes = {
  podSubnets              = "10.244.0.0/16"       # pod subnet
  serviceSubnets          = "10.96.0.0/12"        # svc subnet
  domain                  = "cluster.local"       # cluster local kube-dns svc.cluster.local
  ipv4_vip                = "10.10.10.200"           # vip ip address
  apiDomain               = "api.cluster.local"   # cluster endpoint
  talos-version           = "v1.4.5"              # talos installer version
  metallb_l2_addressrange = "10.10.10.130-10.10.10.145" # metallb L2 configuration ip range
  registry-endpoint       = "10.10.10.201"
  # FLUX ConfigMap settings
  sidero-endpoint = "10.10.10.135"
  cluster-0-vip   = "10.10.10.140"
  cluster-flux-vip   = "10.10.10.141"
}