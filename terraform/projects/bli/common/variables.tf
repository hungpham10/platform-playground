variable "name" {
  type = string
}

variable "bastion" {
  type = string
}

variable "proxmox" {
  type = object({
    host : string
    port : number
    password : string
    private_key : string
    cluster : object({
      size : number
      id : number
    })
  })
}

variable "debug" {
  type = bool
}

variable "vmid" {
  type = number
}

variable "repository" {
  type = string
}

variable "playbooks" {
  type = object({
    gateway = string
  })
}

variable "gateway" {
  type = object({
    cpu:    number
    memory: number
    disks:  list(object({
    }))
    ip_beg: object({
      internet: string
      internal: string
    })
    ip_end: object({
      internet: string
      internal: string
    })
  })
}

variable "total_partition" {
  type = number
}

variable "vault" {
  type = object({
    enabled : bool
    secret : string
    id : string
    project : string
    application : string
    organization : string
  })
}

variable "telegram" {
  type = object({
    token:   string
    chat_id: string
  })
}

variable "promtail" {
  type = object({
    username : string
    password : string
    endpoint : string
    messages : string
  })
}

variable "internet" {
  type = object({
    bridge:   string
    gateway:  string
    ip_range: string
    routes:   object({
      to : string
      via : string
    })
  })
}

variable "internal" {
  type = object({
    bridge:   string
    gateway:  string
    ip_range: string
    routes:   object({
      to : string
      via : string
    })
  })
}

variable "ifaces" {
  type = list(string)
}
