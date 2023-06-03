provider "harbor" {
  url      = "${var.cache_registry_ip}"
  username = "admin"
  password = "${var.harbor_admin_password}"
}