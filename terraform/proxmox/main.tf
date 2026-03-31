resource "proxmox_vm_qemu" "k8s-master" {
  name        = "k8s-master"
  target_node = var.proxmox_node
  clone       = var.template_name
  cores       = 2
  memory      = 4096
  vmid        = 100 
  scsihw      = "virtio-scsi-pci"
  agent       = 1 
  disk {
    slot = "scsi0"
    storage = var.storage
    size    = "20G"
    type    = "disk"
  }
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }
  os_type   = "cloud-init"
  ciuser    = "ubuntu"
  cicustom    = "network=local:snippets/network-master.yaml" 
  ipconfig0 = "ip=10.0.0.10/24,gw=10.0.0.1"
  sshkeys   = file(var.ssh_public_key)
}

resource "proxmox_vm_qemu" "k8s-worker1" {
  name        = "k8s-worker1"
  target_node = var.proxmox_node
  clone       = var.template_name
  cores       = 2
  memory      = 4096
  vmid        = 101
  scsihw      = "virtio-scsi-pci"
  agent       = 1 
 
 disk {
    slot = "scsi0"
    storage = var.storage
    size    = "20G"
    type    = "disk"
  }
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }
  os_type   = "cloud-init"
  ciuser    = "ubuntu"
  cicustom    = "network=local:snippets/network-worker1.yaml" 
  ipconfig0 = "ip=10.0.0.11/24,gw=10.0.0.1"
  sshkeys   = file(var.ssh_public_key)
 depends_on = [proxmox_vm_qemu.k8s-master]
}

resource "proxmox_vm_qemu" "k8s-worker2" {
  name        = "k8s-worker2"
  target_node = var.proxmox_node
  clone       = var.template_name
  cores       = 2
  memory      = 4096
  vmid        = 102
  scsihw      = "virtio-scsi-pci"
  agent       = 1

  disk {
    slot = "scsi0"
    storage = var.storage
    size    = "20G"
    type    = "disk"
  }
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }
  os_type   = "cloud-init"
  ciuser  = "ubuntu"
  cicustom = "network=local:snippets/network-worker2.yaml"
  ipconfig0 = "ip=10.0.0.12/24,gw=10.0.0.1"
  sshkeys   = file(var.ssh_public_key)
  depends_on = [proxmox_vm_qemu.k8s-worker1]
}
