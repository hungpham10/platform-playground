variable "name" {
  description = "The cluster name"
  type        = string
}

variable "vtep" {
  description = "The virtual gateway where internal CIDR traffic will be exposed to access"
  type = object({
    this : object({
      ip : object({
        cidr : string
        lb : string
      })
      pubkey : string
      privkey : string
    })
    peer : object({
      ip : string
      pubkey : string
      privkey : string
    })
    subnet : string
    enable : bool
    bastion : string
  })
  default = {
    enable  = false
    subnet  = ""
    bastion = ""
    this = {
      ip = {
        cidr = ""
        lb   = ""
      }
      pubkey  = ""
      privkey = ""
    }
    peer = {
      ip      = ""
      pubkey  = ""
      privkey = ""
    }
  }
}

variable "vmid" {
  description = "The first VM id which we will used to define the proxmox's node id"
  type        = number
}

variable "partition" {
  description = "The partition id which is used to calculate the real vmid of every node"
  type        = number
}

variable "group_public_keys" {
  description = "The list of public keys"
  type        = list(string)
  default     = []
}

variable "total_partition" {
  description = "The number of partition id we would like to use"
  type        = number
}

variable "control_plan_ip" {
  description = "The control-plan cluster ip which will be used as the kube-apiserver"
  type        = string
}

variable "nfs_persistence_volume_ip" {
  description = "The nfs pool ip which will be used as a persistence volume provider"
  type        = string
  default     = ""
}

variable "nfs_elphemera_volume_ip" {
  description = "The nfs pool ip which will be used as an elphemera volume provider"
  type        = string
  default     = ""
}

variable "is_development_environment" {
  description = "Is this infrastructure used for development only or not?"
  type        = string
  default     = "false"
}

variable "is_internal_environment" {
  description = "Is this infrastructure used for internal intention only or not?"
  type        = string
  default     = "false"
}

variable "is_platform_environment" {
  description = "Is this infrastructure used for building platform system only or not?"
  type        = string
  default     = "false"
}

variable "topdir" {
  description = "The topdir where store every module"
  type        = string
}

variable "repository" {
  description = "The ansible repository where is located playbooks to provision nodes"
  type        = string
}

variable "branch" {
  description = "The ansible repository's branch where which will be used to promote the new infrastructure"
  type        = string
}

variable "cidr_range" {
  description = "The cidr range which is used to isolate traffic between clusters when we start VPN peering between of them"
  type = object({
    pod : string
    service : string
  })
  default = {
    pod     = "10.244.0.0/16"
    service = "10.96.0.0/16"
  }
}


variable "infrastructure_config_map" {
  description = "The infrastructure config map which is used to configure the whole cluster"
  type        = string
  default     = ""
}

variable "network_policy" {
  description = "The kubernetes network policy"
  type        = string
  default     = "flannel"
}

variable "metric" {
  description = "The number of node dedicated to be deployed to cloud"
  type = number
  default = 0
}

variable "iothread" {
  description = "The number of io thread for specific node"
  type        = number
  default     = 1
}

variable "template" {
  description = "The base image using to deploy specific node"
  type        = string
  default     = "NodeTemplate"
}

variable "cpus" {
  description = "The number of CPUs to give to the virtual machine during the build"
  type = string
  default = "2"
}

variable "sockets" {
  description = "The number of CPUs to give to the virtual machine during the build"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "The amount of memory to give to the virtual machine during the build"
  type = string
  default = "2048"
}

variable "disks" {
  description = "Disk Size for the primary drive"
  type = object({
    master : list(object({
      name : string
      size : string
      pool : string
    }))
    worker : list(object({
      name : string
      size : string
      pool : string
    }))
  })
}

variable "coredns_ip" {
  description = "The static ip of coredns service"
  type        = string
  default     = "10.96.0.10"
}

variable "lb_range" {
  description = "The range of ip which will be used to asign to services which stands as frontend services"
  type = object({
    public : string
    private : string
  })
  default = {
    public  = "192.168.2.80-192.168.2.250"
    private = "10.80.10.230-10.80.10.250"
  }
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

variable "networks" {
  description = "Network configuration"
  type = list(object({
    kind : string
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

variable "gateway" {
  description = "The gateway where traffic will be aggregated"
  type        = string
  default     = "10.88.10.254"
}

variable "nameserver" {
  description = "The DNS server which is used to convert hostname to dedicated ip address"
  type        = string
  default     = "8.8.8.8"
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

variable "user_script" {
  description = "The user script which will be used to call for troubleshooting or doing some specific things"
  type        = string
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

variable "prometheus" {
  description = "The prometheus defintion"
  type = list(object({
    endpoint : string
    username : string
    password : string
  }))
  default = []
}

variable "tfe" {
  description = "The terraform cloud definition"
  type = object({
    organization : string
    workspace : string
    token : string
  })
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
    bridge : string
    password : string
    private_key : string
    cluster : object({
      size : number
      id : number
    })
  })
}

variable "kubernetes" {
  description = "Contain inventory configuration of the whole kubernetes cluster"
  type = object({
    masters : object({
      hosts : list(string)
      disks : list(list(object({
        name : string
        size : number
      })))
    })
    workers : object({
      hosts : list(string)
      names : list(string)
      ip : list(string)
      kinds : list(string)
      groups : list(string)
      disks : list(list(object({
        name : string
        size : number
      })))
    })
  })
}

variable "debug" {
  description = "Take this flow as debuging flow so VM could  be recreate"
  type        = bool
  default     = false
}

variable "flags" {
  description = "Flags to control behavior of this module"
  type = object({
    enable_elastic_network : bool
    enable_notify_when_done : bool
    enable_pvc_template : bool
  })
  default = {
    enable_elastic_network  = false
    enable_notify_when_done = false
    enable_pvc_template     = true
  }
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

variable "instruction_folder" {
  description = "The folder whhich contains everything to help to setup and configure connectivity between nodes"
  type        = string
}
