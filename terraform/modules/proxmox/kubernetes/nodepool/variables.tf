
variable "name" {
  description = "The cluster name"
  type        = string
}

variable "vmid" {
  description = "The first VM id which we will used to define the proxmox's node id"
  type        = number
}

variable "layer" {
  description = "The number indicates where to be the first layer to calculate VM id of specific partition"
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

variable "node_type" {
  description = "The node type which define the role of this node incluster"
  type        = string
}

variable "control_plan_ip" {
  description = "The control-plan cluster ip which will be used as the kube-apiserver"
  type        = string
}

variable "is_development_environment" {
  description = "Is this infrastructure used for development only or not?"
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

variable "playbook" {
  description = "The ansible playbook which is used to provision nodes"
  type        = string
}

variable "ansible_config_map" {
  description = "The ansible config map which is used to custom nodes automatically"
  type = object({
    data : string
    path : string
  })
  default = {
    data = ""
    path = ""
  }
}

variable "infrastructure_config_map" {
  description = "The infrastructure config map which is used to configure the whole cluster"
  type        = string
  default     = ""
}

variable "nameserver" {
  description = "The DNS server which is used to convert hostname to dedicated ip address"
  type        = string
  default     = "8.8.8.8"
}

variable "metric" {
  description = "The number of node dedicated to be deployed to cloud"
  type        = number
  default     = 0
}

variable "iothread" {
  description = "The number of io thread for specific node"
  type        = number
  default     = 1
}

variable "opts" {
  description = "The advance configuration to tune the system more robusness"
  type = object({
    disk : object({
      mbps : number
      mbps_rd : number
      mbps_wr : number
      mbps_rd_max : number
      mbps_wr_max : number
    })
  })
  default = {
    disk = {
      mbps        = 0
      mbps_rd     = 0
      mbps_wr     = 0
      mbps_rd_max = 0
      mbps_wr_max = 0
    }
  }
}

variable "template" {
  description = "The base image using to deploy specific node"
  type        = string
  default     = "NodeTemplate"
}

variable "cpu" {
  description = "The number of CPUs to give to the virtual machine during the build"
  type        = string
  default     = "2"
}

variable "socket" {
  description = "The number of CPUs to give to the virtual machine during the build"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "The amount of memory to give to the virtual machine during the build"
  type        = string
  default     = "4086"
}

variable "disks" {
  description = "Disk Size for the primary drive"
  type = list(object({
    name : string
    size : string
    pool : string
  }))
}

variable "ip" {
  description = "The alias ip address of nodes, stand as endpoint of specific resource"
  type        = string
  default     = "10.88.10.206"
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

variable "gateway" {
  description = "The gateway where traffic will be aggregated"
  type        = string
  default     = "10.88.10.254"
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

variable "cloud_init_config_file" {
  description = "The cloud init config files on proxmox server that we would like to use"
  type        = string
  default     = ""
}

variable "user_script" {
  description = "The user script which will be used to call for troubleshooting or doing some specific things"
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

variable "carbon" {
  description = "The carbon-relay-ng definition"
  type = object({
    endpoint : string
    apikey : string
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

variable "redistore" {
  type = object({
    endpoint : string
    port : string
    database : string
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

variable "ansible_extra_vars" {
  description = "The ansible extra vars which has been shared among ansible hosts"
  type        = string
  default     = ""
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
    enable_pvc_template : bool
  })
  default = {
    enable_elastic_network = false
    enable_pvc_template    = true
  }
}

variable "install_with_hostname" {
  description = "This flag is used to indidate whether or not to setup node with dedicated ansible playbooks"
  type        = bool
  default     = false
}

variable "instruction_folder" {
  description = "The folder whhich contains everything to help to setup and configure connectivity between nodes"
  type        = string
}
