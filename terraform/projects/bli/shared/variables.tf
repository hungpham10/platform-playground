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
  type = number
}

variable "total_partition" {
  description = "Total number of partition of this project"
  type = number
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
  type = object({
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
}

variable "postgres" {
  description = "Postgres definition"
  type = object({
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
}

