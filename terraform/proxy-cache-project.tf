resource "harbor_project" "docker" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-docker.io"
  registry_id = harbor_registry.docker.registry_id
}

resource "harbor_project" "ghcr" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-ghcr.io"
  registry_id = harbor_registry.ghcr.registry_id
}

resource "harbor_project" "gcr" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-gcr.io"
  registry_id = harbor_registry.gcr.registry_id
}

resource "harbor_project" "registry-k8s" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-registry.k8s.io"
  registry_id = harbor_registry.registry-k8s.registry_id
}

resource "harbor_project" "quay" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-quay.io"
  registry_id = harbor_registry.quay.registry_id
}