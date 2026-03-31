#!/bin/bash
set -e

PROXMOX_HOST="root@62.210.89.8"
ANSIBLE_INVENTORY="~/devops-infra/ansible/inventory.ini"

echo "=========================================="
echo "  DÉPLOIEMENT INFRASTRUCTURE K8S"
echo "=========================================="

# Étape 1 - Créer les VMs
echo ""
echo ">>> Étape 1 : Création des VMs avec Terraform..."
cd ~/devops-infra/terraform/proxmox
terraform apply -auto-approve

# Étape 2 - Attendre que les VMs démarrent
echo ""
echo ">>> Étape 2 : Attente du démarrage des VMs (60s)..."
sleep 60

# Étape 3 - Configurer les IPs des workers
echo ""
echo ">>> Étape 3 : Configuration réseau des workers..."
ssh $PROXMOX_HOST "qm guest exec 101 -- bash -c 'cat > /etc/netplan/51-static.yaml << EOF
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses: [10.0.0.11/24]
      routes:
        - to: default
          via: 10.0.0.1
      nameservers:
        addresses: [8.8.8.8]
EOF
netplan apply'"

ssh $PROXMOX_HOST "qm guest exec 102 -- bash -c 'cat > /etc/netplan/51-static.yaml << EOF
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses: [10.0.0.12/24]
      routes:
        - to: default
          via: 10.0.0.1
      nameservers:
        addresses: [8.8.8.8]
EOF
netplan apply'"

# Étape 4 - Vérifier la connectivité Ansible
echo ""
echo ">>> Étape 4 : Vérification connectivité Ansible..."
sleep 30

if ansible -i $ANSIBLE_INVENTORY all -m ping; then
    echo ""
    echo "=========================================="
    echo "  INFRASTRUCTURE PRÊTE !"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "  ERREUR : Une ou plusieurs VMs sont"
    echo "  injoignables. Vérifiez les logs."
    echo "=========================================="
    exit 1
fi
