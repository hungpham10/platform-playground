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
    memory = 4096
    metric = 1
    disks =  []
    ip_beg = {
      internet = 101
      internal = 2
    }
    ip_end = {
      internet = 103
      internal = 4
    }
  }

  gateway  = {
    partition = 1
    cpu = 1
    memory = 4096
    metric = 1
    disks =  [
      {
        name = "/dev/sda"
        size = "10G"
        pool = "VM2"
      }
    ]
    ip_beg = {
      internet = 100
      internal = 1
    }
    ip_end = {
      internet = 101
      internal = 2
    }
  }
  
  internet = {
    bridge   = "vmbr0"
    gateway  = "192.168.2.1"
    ip_range = "192.168.2.%d"
    netmask  = {
      long  = "255.255.255.0"
      short = "24"
    }
    routes   = []
  }

  internal = {
    bridge   = "vmbr10"
    gateway  = "10.188.10.1"
    ip_range = "10.188.10.%d"
    netmask  = {
      long  = "255.255.255.0"
      short = "24"
    }
    routes   = []
  }

  vmid = 1234
  total_partition = 4
}
