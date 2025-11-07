variable "networks" {
  description = "Network configuration"
  type = list(object({
    bridge: string
    iface: string
    gateway: string
    ip_range: string
    ip_beg: number
    ip_end: number
    routes: list(object({
      to: string
      via: string
    }))
  }))
}

variable "metric" {
  description = "Number of instance"
  type        = number
}

variable "netmask" {
  description = "The netmask of the primary network"
  type = object({
    long : string
    short : string
  })
  default = {
    long  = "255.255.255.0"
    short = "24"
  }
}

variable "proxmox" {
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
