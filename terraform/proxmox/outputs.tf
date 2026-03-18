output "k8s-master-ip" {
  value = proxmox_vm_qemu.k8s-master.default_ipv4_address
}

output "k8s-worker1-ip" {
  value = proxmox_vm_qemu.k8s-worker1.default_ipv4_address
}

output "k8s-worker2-ip" {
  value = proxmox_vm_qemu.k8s-worker2.default_ipv4_address
}
