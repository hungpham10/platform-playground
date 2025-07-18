locals {
  organization = "Alpaca"
  workspace    = "proxmox"
  proxmox      = {
      api         = "https://192.168.2.201:8006/api2/json"
      host        = "192.168.2.201"
      port        = 22
      node        = "pve"
      token       = "root@pam!alpaca-devops-token"
      secret      = "a4c17f0f-e9a8-4591-b6e4-83d3c87b900b"
      password    = "Alpaca#2020"
      private_key = ""
      cluster     = {
        size = 1
        id = 0
      }
  }
}
