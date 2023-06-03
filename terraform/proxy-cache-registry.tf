resource "harbor_registry" "docker" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "docker-hub"
  name          = "proxy-docker.io"
  endpoint_url  = "https://hub.docker.com"
  depends_on = [
    proxmox_vm_qemu.container-registry
  ]
}

resource "harbor_registry" "ghcr" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "github"
  name          = "proxy-ghcr.io"
  endpoint_url  = "https://https://ghcr.io"
  depends_on = [
    proxmox_vm_qemu.container-registry
  ]
}

resource "harbor_registry" "gcr" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "google"
  name          = "proxy-gcr.io"
  endpoint_url  = "https://gcr.io"
  depends_on = [
    proxmox_vm_qemu.container-registry
  ]
}

resource "harbor_registry" "registry-k8s" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "docker-registry"
  name          = "proxy-registry.k8s.io"
  endpoint_url  = "https://registry.k8s.io"
  depends_on = [
    proxmox_vm_qemu.container-registry
  ]
}

resource "harbor_registry" "quay" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "docker-registry"
  name          = "proxy-quay.io"
  endpoint_url  = "https://quay.io/"
  depends_on = [
    proxmox_vm_qemu.container-registry
  ]
}