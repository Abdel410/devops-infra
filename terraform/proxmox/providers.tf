terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://62.210.89.8:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "2d5f17bb-594c-42db-b340-07c094df6384"
  pm_tls_insecure     = true
}
