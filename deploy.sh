#!/bin/bash
set -e

PROXMOX_HOST="root@62.210.89.8"
ANSIBLE_INVENTORY="~/devops-infra/ansible/inventory.ini"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  DÉPLOIEMENT INFRASTRUCTURE K8S"
echo "=========================================="

# Étape 1 - Créer les VMs
echo ""
echo -e "${YELLOW}>>> Étape 1 : Création des VMs avec Terraform...${NC}"
cd ~/devops-infra/terraform/proxmox
terraform apply -auto-approve

# Étape 2 - Attendre que les VMs démarrent
echo ""
echo -e "${YELLOW}>>> Étape 2 : Attente du démarrage des VMs (90s)...${NC}"
sleep 90

# Étape 3 - Configuration réseau et système
echo ""
echo -e "${YELLOW}>>> Étape 3 : Configuration réseau et système...${NC}"

# Master
ssh $PROXMOX_HOST "qm guest exec 100 -- bash -c 'hostnamectl set-hostname k8s-master && echo 127.0.0.1 k8s-master >> /etc/hosts'"

# Worker1 - IP unique 10.0.0.11
ssh $PROXMOX_HOST "qm guest exec 101 -- bash -c 'hostnamectl set-hostname k8s-worker1 && echo 127.0.0.1 k8s-worker1 >> /etc/hosts && ip addr del 10.0.0.10/24 dev ens18; cat > /etc/netplan/01-netcfg.yaml << EOF
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

# Worker2 - IP unique 10.0.0.12
ssh $PROXMOX_HOST "qm guest exec 102 -- bash -c 'hostnamectl set-hostname k8s-worker2 && echo 127.0.0.1 k8s-worker2 >> /etc/hosts && ip addr del 10.0.0.10/24 dev ens18; cat > /etc/netplan/01-netcfg.yaml << EOF
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
echo -e "${YELLOW}>>> Étape 4 : Vérification connectivité Ansible...${NC}"
sleep 30

if ansible -i $ANSIBLE_INVENTORY all -m ping; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "  INFRASTRUCTURE PRÊTE !"
    echo -e "==========================================${NC}"
else
    echo ""
    echo -e "${RED}=========================================="
    echo "  ERREUR : Une ou plusieurs VMs sont"
    echo "  injoignables. Vérifiez les logs."
    echo -e "==========================================${NC}"
    exit 1
fi
