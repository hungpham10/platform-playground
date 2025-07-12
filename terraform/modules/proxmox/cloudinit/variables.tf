variable "name" {
  description = "The cluster name"
  type        = string
}

variable "username" {
  description = "The default username for the OS"
  type        = string
  default     = "vagrant"
}

variable "password" {
  description = "The password for the the default user for the OS"
  type        = string
  default     = "vagrant"
}

variable "node_type" {
  description = "The node type which define the role of these nodes"
  type        = string
}

variable "format" {
  description = "The format node we would like to use, only have two choice, vm or k8s"
  type        = string
  default     = "vm"
}

variable "installer" {
  description = "The IP address of node installer where contains installation resource"
  type        = string
  default     = ""
}

variable "flags" {
  description = ""
  type        = object({
    use_elastic_network: bool
    use_notify_when_done: bool
    use_agent: bool
    use_statefulset_strategy: bool
  })
}

variable "networks" {
  description = "Network configuration"
  type = list(object({
    bridge : string
    iface : string
    gateway : string
    ip_range : string
    ip_beg : number
    ip_end : number
    routes : list(object({
      to : string
      via : string
    }))
  }))
}

variable "disks" {
  description = "Storage configuration"
  type = list(object({
    name : string
    size : string
    pool : string
  }))
}

variable "topdir" {
  description = "The topdir where store every module"
  type        = string
}

variable "metric" {
  description = "The number of node dedicated to be deployed to cloud"
  type        = number
  default     = 1
}

variable "repository" {
  description = "The ansible repository where is located playbooks to provision nodes"
  type        = string
  default     = ""
}

variable "branch" {
  description = "The ansible repository's branch where which will be used to promote the new infrastructure"
  type        = string
}

variable "playbook" {
  description = "The ansible playbook which is used to provision nodes"
  type        = string
  default     = ""
}

variable "tls_key" {
  description = "The pair public/private keys which are used to configure cluster"
  type = object({
    pubkey : string
    privkey : string
  })
  default = {
    pubkey  = ""
    privkey = ""
  }
}

variable "telegram" {
  description = "The telegram bot definition"
  type = object({
    token : string
    chat_id : string
  })
}

variable "promtail" {
  description = "The promtail definition"
  type = object({
    username : string
    password : string
    endpoint : string
    messages : string
  })
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

variable "vault" {
  description = "Vault client secret and project name to access configuration from outside"
  type = object({
    enabled : bool
    secret : string
    id : string
    project : string
    application : string
    organization : string
  })
  default = {
    enabled      = false
    secret       = ""
    id           = ""
    project      = ""
    application  = ""
    organization = ""
  }
}

variable "iptables" {
  description = "The iptables api server which is used to configure the node's firewall"
  type = object({
    enabled : bool
    version : string
    port : number
  })
  default = {
    enabled = true
    version = "1.17"
    port    = 1080
  }
}

variable "infrastructure_config_map" {
  description = "The infrastructure config map which is used to configure the whole cluster"
  type = string
  default = ""
}

variable "instruction_folder" {
  description = "The folder whhich contains everything to help to setup and configure connectivity between nodes"
  type        = string
}
