// ---------------------------------------- //
variable "name" {
  description = "The project name"
  type        = string
}

variable "bastion" {
  description = "The bastion configuration"
  type        = string
  default     = ""
}

variable "proxmox" {
  description = "The proxmox configuration"
  type = object({
    api : string
    host : string
    port : number
    node : string
    token : string
    timeout : number
    secret : string
    password : string
    private_key : string
    cluster : object({
      size : number
      id : number
    })
  })
}

variable "vmid" {
  description = "The first vmid which define the cluster id"
  type        = number
  default     = 1234
}

variable "total_partition" {
  description = "Total number of partition of this project"
  type        = number
  default     = 4
}

variable "internet" {
  description = "Define routing between nodes and the internet bridge"
  type = object({
    bridge:   string
    gateway:  string
    ip_range: string
    netmask:  object({
      long : string
      short : string
    })
    routes:   list(object({
      to : string
      via : string
    }))
  })
  default = {
    bridge   = "vmbr0"
    gateway  = "192.168.2.1"
    ip_range = "192.168.2.%d"
    netmask  = {
      long  = "255.255.255.0"
      short = "24"
    }
    routes   = []
  }
}

variable "internal" {
  description = "Define routing between nodes and the internal bridge"
  type = object({
    bridge:   string
    gateway:  string
    ip_range: string
    netmask:  object({
      long : string
      short : string
    })
    routes:   list(object({
      to : string
      via : string
    }))
  })
  default = {
    bridge   = "vmbr10"
    gateway  = "10.188.10.1"
    ip_range = "10.188.10.%d"
    netmask  = {
      long  = "255.255.255.0"
      short = "24"
    }
    routes   = []
  }
}

variable "ifaces" {
  description = "List of interfaces"
  type        = list(string)
  default     = [
    "enp4s3",
    "enp4s4"
  ]
}

// ---------------------------------------- //
variable "gateway" {
  description = "Gateway definition"
  type        = object({
    cpu:       number
    memory:    number
    metric:    number
    partition: number
    disks:     list(object({
      name : string
      size : string
      pool : string
    }))
    ip_beg:    object({
      internet: number
      internal: number
    })
    ip_end:    object({
      internet: number
      internal: number
    })
  })
  default     = {
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
}

variable "postgres" {
  description = "Postgres definition"
  type        = object({
    cpu:       number
    memory:    number
    metric:    number
    partition: number
    disks:     list(object({
      name : string
      size : string
      pool : string
    }))
    ip_beg:    object({
      internet: number
      internal: number
    })
    ip_end:    object({
      internet: number
      internal: number
    })
  })
  default     = {
    partition = 2
    cpu = 4
    memory = 4096
    metric = 1
    disks =  [
      {
        name = "/dev/sda"
        size = "10G"
        pool = "VM1"
      },
      {
        name = "/dev/sdb"
        size = "100G"
        pool = "VM2"
      }
    ]
    ip_beg = {
      internet = 101
      internal = 2
    }
    ip_end = {
      internet = 103
      internal = 4
    }
  }
}

variable "kubernetes" {
  description = "Kubernetes definition"
  type        = object(
    master: object({
      cpu:       number
      memory:    number
      metric:    number
      partition: number
      disks:     list(object({
        name : string
        size : string
        pool : string
      }))
      ip_beg:    object({
        internet: number
        internal: number
      })
      ip_end:    object({
        internet: number
        internal: number
      })
    })
  })
  default     = {
    master = {
      partition = 3
      cpu = 1
      memory = 1024
      metric = 1
      disks =  [
        {
          name = "/dev/sda"
          size = "5G"
          pool = "VM2"
        },
      ]
      ip_beg = {
        internet = 103
        internal = 4
      }
      ip_end = {
        internet = 104
        internal = 5
      }
    }
  }
}

