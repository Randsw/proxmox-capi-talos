variable "region" {
  description = "Equal to Proxmox cluster name"
  type        = string
  default     = "pve"
}

variable "pool" {
  description = "Resource pool in Proxmox"
  type        = string
  default     = "prod"
}

variable "proxmox_host" {
  description = "Proxmox host"
  type        = string
  default     = "192.168.1.1"
}

variable "proxmox_image" {
  description = "Proxmox source image name"
  type        = string
  default     = "talos"
}

variable "proxmox_storage1" {
  description = "Proxmox storage name"
  type        = string
}

variable "proxmox_storage2" {
  description = "Proxmox storage name"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox token id"
  type        = string
}

variable "proxmox_token_secret" {
  description = "Proxmox token secret"
  type        = string
}

variable "target_node_name" {
  description = "Proxmox node name for CP"
  type        = string
}

variable "gateway" {
  type    = string
  default = "10.1.1.1"
}

variable "cache_registry_ip" {
  description = "Proxy cache registry ip address"
  type = string
}

variable "proxmox_registry_image" {
  description = "Proxy cache registry image template"
  default = "harbor-ubuntu"
  type = string
}

variable "enable_cache_registry" {
  description = "Enable proxy cache container registry deployment"
  type = bool
  default = true
}

variable "harbor_admin_password" {
  description = "Admin password for Harbor container registry"
  type = string
  default = "admin"
}

variable "harbor_vmid" {
  description = "VM ID for Harbor"
  type = string
  default = "200"
}