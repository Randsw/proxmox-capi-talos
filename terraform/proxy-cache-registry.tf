resource "harbor_registry" "docker" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "docker-hub"
  name          = "proxy-docker.io"
  endpoint_url  = "https://hub.docker.com"
}

resource "harbor_registry" "ghcr" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "github"
  name          = "proxy-ghcr.io"
  endpoint_url  = "https://https://ghcr.io"
}

resource "harbor_registry" "gcr" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "google"
  name          = "proxy-gcr.io"
  endpoint_url  = "https://gcr.io"
}

resource "harbor_registry" "registry-k8s" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "docker-registry"
  name          = "proxy-registry.k8s.io"
  endpoint_url  = "https://registry.k8s.io"
}

resource "harbor_registry" "quay" {
  count       = var.enable_cache_registry ? 1 : 0
  provider_name = "docker-registry"
  name          = "proxy-quay.io"
  endpoint_url  = "https://quay.io/"
}