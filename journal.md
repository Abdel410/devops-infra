# Journal de bord - Projet DevOps

## 16 mars 2026
### Ce que j'ai fait
- Lecture et analyse du sujet de projet
- Choix de l'application : Online Boutique (microservices e-commerce Google)
- Définition de la problématique et des choix techniques
- Création des 3 repos GitHub : devops-app, devops-infra, devops-manifests
- Push du code Online Boutique sur devops-app

### Difficultés rencontrées
- Problème de token GitHub lors du push (résolu en ajoutant la permission workflow)
- Branche master/main à harmoniser (résolu avec git branch -m et git push --force)

## 18 mars 2026
### Ce que j'ai fait
- Connexion et exploration du serveur Proxmox
- Configuration SSH : activation de PermitRootLogin et PasswordAuthentication
- Redémarrage du service sshd pour appliquer les changements
- Connexion SSH réussie depuis le Mac vers Proxmox

### Difficultés rencontrées
- Permission denied en SSH malgré bon mot de passe
- Cause : directives SSH commentées dans /etc/ssh/sshd_config
- Résolution : sed -i pour décommenter + systemctl restart sshd



## 18 mars 2026
### Ce que j'ai fait
- Création du template Ubuntu 22.04 sur Proxmox
- Configuration du bridge réseau privé vmbr1 (10.0.0.x)
- Configuration du NAT pour accès internet des VMs
- Écriture des fichiers Terraform : providers.tf, variables.tf, main.tf, outputs.tf
- Push sur GitHub devops-infra

### Difficultés rencontrées
- IPs publiques utilisées par erreur → corrigé en créant un réseau privé vmbr1
- Règle iptables non persistante → résolu avec iptables-persistent



## 29 mars 2026

### Ce que j'ai fait
- Installation de Terraform sur Mac (version 1.7.0)
- Génération d'une clé SSH pour l'injection dans les VMs
- Initialisation du projet Terraform : terraform init
- Simulation du déploiement : terraform plan
- Déploiement des 3 VMs sur Proxmox : terraform apply
- Correction de plusieurs erreurs successives

### Difficultés rencontrées et solutions

**Problème 1 : Plugin Terraform v2.9.14 crashait**
- Erreur : `panic: interface conversion: interface {} is string, not float64`
- Cause : bug connu dans la version 2.9.14 du plugin telmate/proxmox
- Solution : mise à jour vers la version 3.0.1-rc4 via `terraform init -upgrade`

**Problème 2 : Argument `slot` manquant**
- Erreur : `slot must be one of 'scsi0', 'ide0'...`
- Cause : le nouveau plugin demande le nom complet du slot
- Solution : remplacer `slot = 0` par `slot = "scsi0"` et `type = "disk"`

**Problème 3 : Conflits d'IDs entre VMs**
- Erreur : `unable to create VM 100: config file already exists`
- Cause : Terraform créait les 3 VMs en parallèle, elles se battaient pour l'ID 100
- Solution 1 : ajout de `depends_on` pour créer les VMs séquentiellement
- Solution 2 : ajout de `vmid` fixes (100, 101, 102) pour éviter tout conflit

**Problème 4 : Fichiers de configuration résiduels**
- Erreur : `VM 100 already running`
- Cause : après destruction des VMs, des fichiers .conf restaient sur Proxmox
- Solution : suppression manuelle avec `qm destroy --purge --skiplock`

### Résultat final
- 3 VMs créées avec succès sur Proxmox :
  - 100 (k8s-master)  : 10.0.0.10 - 2 CPU - 4Go RAM - 20Go disque
  - 101 (k8s-worker1) : 10.0.0.11 - 2 CPU - 4Go RAM - 20Go disque
  - 102 (k8s-worker2) : 10.0.0.12 - 2 CPU - 4Go RAM - 20Go disque
- Infrastructure reproductible et déterministe grâce aux vmid fixes

### Ce que j'ai appris
- Différence entre terraform plan (simulation) et terraform apply (déploiement réel)
- Importance des vmid fixes pour éviter les conflits lors de créations parallèles
- Gestion des fichiers résiduels Proxmox avec --purge et --skiplock
- Le principe de l'IaC : infrastructure déterministe et reproductible
