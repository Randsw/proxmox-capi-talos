resource "harbor_project" "docker" {
  name        = "proxy-docker.io"
  public      = false
  registry_id = harbor_registry.docker.registry_id
  depends_on = [
    harbor_registry.docker
  ]
}

resource "harbor_project" "ghcr" {
  name        = "proxy-ghcr.io"
  public      = false
  registry_id = harbor_registry.ghcr.registry_id
  depends_on = [
    harbor_registry.ghcr
  ]
}

resource "harbor_project" "gcr" {
  name        = "proxy-gcr.io"
  public      = false
  registry_id = harbor_registry.gcr.registry_id
  depends_on = [
    harbor_registry.gcr
  ]
}

resource "harbor_project" "registry-k8s" {
  name        = "proxy-registry.k8s.io"
  public      = false
  registry_id = harbor_registry.registry-k8s.registry_id
  depends_on = [
    harbor_registry.registry-k8s
  ]
}

resource "harbor_project" "quay" {
  name        = "proxy-quay.io"
  public      = false
  registry_id = harbor_registry.quay.registry_id
  depends_on = [
    harbor_registry.quay
  ]
}