terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://62.210.89.8:8006/api2/json"
  pm_api_token_id     = var.proxmox_token_secretid
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true
}
