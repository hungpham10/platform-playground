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
      timeout     = 60
      cluster     = {
        size = 1
        id = 0
      }
  }

  postgres = {
    partition = 2
    cpu = 4
    memory = 4
    metric = 1
    disks =  []
    ip_beg = {
      internet = 2
      internal = 2
    }
    ip_end = {
      internet = 4
      internal = 4
    }
  }

  gateway  = {
    partition = 2
    cpu = 1
    memory = 4
    metric = 1
    disks =  []
    ip_beg = {
      internet = 1
      internal = 1
    }
    ip_end = {
      internet = 2
      internal = 2
    }
  }
  
  internet = {
    bridge   = "vmbr1"
    gateway  = "192.168.1.1"
    ip_range = "192.168.1.%d"
    netmask  = {
      long  = "255.255.255.0"
      short = "24"
    }
    routes   = []
  }

  internal = {
    bridge   = "vmbr2"
    gateway  = "192.168.2.1"
    ip_range = "192.168.2.%d"
    netmask  = {
      long  = "255.255.255.0"
      short = "24"
    }
    routes   = []
  }

  vmid = 1234
  total_partition = 4
}
