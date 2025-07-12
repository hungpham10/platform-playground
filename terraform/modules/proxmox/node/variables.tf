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

variable "vmid" {
  description = "The first VM id which we will used to define the proxmox's node id"
  type        = number
}

variable "partition" {
  description = "The partition id which is used to calculate the real vmid of every node"
  type        = number
}

variable "total_partition" {
  description = "The number of partition id we would like to use"
  type        = number
}

variable "debug" {
  description = "Take this flow as debuging flow so VM could  be recreate"
  type        = bool
  default     = false
}

variable "bastion" {
  description = "Whether or not we must access this instance by a bastion"
  type        = string
  default     = ""
}

variable "layer" {
  description = "The number indicates where to be the first layer to calculate VM id of specific partition"
  type        = number
  default     = 0
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

variable "name" {
  description = "The cluster name"
  type        = string
}

variable "node_type" {
  description = "The node type which define the role of this node incluster"
  type        = string
}

variable "topdir" {
  description = "The topdir where store every module"
  type        = string
}

variable "format" {
  description = "The format of nodes, must be vm or k8s only"
  type        = string
  default     = "vm"
}

variable "metric" {
  description = "The number of node dedicated to be deployed to cloud"
  type        = number
  default     = 1
}

variable "iothread" {
  description = "The number of io thread for storage nodes"
  type        = number
  default     = 1
}

variable "template" {
  description = "The base image using to deploy specific node"
  type        = string
  default     = "NodeTemplate"
}

variable "cpu" {
  description = "The number of CPUs to give to the virtual machine during the build"
  type        = string
  default     = "1"
}

variable "cpu_mode" {
  description = "The cpu mode which is used to define the virtualization mode between guest and host"
  type        = string
  default     = "host"
}

variable "socket" {
  description = "The number of CPUs to give to the virtual machine during the build"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "The amount of memory to give to the virtual machine during the build"
  type        = string
  default     = "1024"
}

variable "disks" {
  description = "Disk Size for the primary drive"
  type = list(object({
    name : string
    size : string
    pool : string
  }))
  default = [{
    name = "/dev/sda"
    size = "10G"
    pool = "VM2"
  }]
}

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

variable "groups" {
  description = "List of groups which define "
  type        = list(object({
  }))
  default     = []
}

variable "infrastructure_config_map" {
  description = "The infrastructure config map which is applied to cluster (only available when we don't use agent)"
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

variable "recreate" {
  type    = bool
  default = false
}

variable "flags" {
  description = "Flags to control behavior of this module"
  type = object({
    use_notify_when_done : bool
    use_elastic_network : bool
    use_agent : bool
    use_statefulset_strategy : bool
  })
  default = {
    use_notify_when_done     = false
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
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
  sensitive = true
}

variable "instruction_folder" {
  description = "The folder whhich contains everything to help to setup and configure connectivity between nodes"
  type        = string
}
