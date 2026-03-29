variable "proxmox_node" {
  default = "sd-177086"
}

variable "template_name" {
  default = "ubuntu-template"
}

variable "storage" {
  default = "vmdata"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}


variable "proxmox_token_secretid" {
  description = "Token ID Proxmox API"
  sensitive   = true
}

variable "proxmox_token_secret" {
  description = "Token secret Proxmox API"
  sensitive   = true
}
