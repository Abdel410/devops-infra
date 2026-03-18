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
