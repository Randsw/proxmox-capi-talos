resource "harbor_project" "docker" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-docker.io"
  registry_id = harbor_registry.docker.registry_id
  depends_on = [
    harbor_registry.docker
  ]
}

resource "harbor_project" "ghcr" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-ghcr.io"
  registry_id = harbor_registry.ghcr.registry_id
  depends_on = [
    harbor_registry.ghcr
  ]
}

resource "harbor_project" "gcr" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-gcr.io"
  registry_id = harbor_registry.gcr.registry_id
  depends_on = [
    harbor_registry.gcr
  ]
}

resource "harbor_project" "registry-k8s" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-registry.k8s.io"
  registry_id = harbor_registry.registry-k8s.registry_id
  depends_on = [
    harbor_registry.registry-k8s
  ]
}

resource "harbor_project" "quay" {
  count       = var.enable_cache_registry ? 1 : 0
  name        = "proxy-quay.io"
  registry_id = harbor_registry.quay.registry_id
  depends_on = [
    harbor_registry.quay
  ]
}