variable "tfe" {
  type = object({
    token: string
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
    password : string
    private_key : string
    cluster : object({
      size : number
      id : number
    })
  })
}

variable "topdir" {
  description = "The topdir where store every module"
  type        = string
}

// -------------------------------------------------- //
//
// -------------------------------------------------- //
variable "name" {
  description = "The cluster name"
  type        = string
}

variable "format" {
  description = "The format of nodes, must be vm or k8s only"
  type        = string
  default     = "vm"
}

variable "node_type" {
  description = "The node type which define the role of this node incluster"
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

variable "variables" {
  description = "List of variables"
  default     = {}
}
// -------------------------------------------------- //

// -------------------------------------------------- //
//
// -------------------------------------------------- //
variable "metric" {
  description = "The number of node dedicated to be deployed to cloud"
  type        = number
  default     = 1
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

variable "template" {
  description = "The base image using to deploy specific node"
  type        = string
  default     = "NodeTemplate"
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

variable "iothread" {
  description = "The number of io thread for storage nodes"
  type        = number
  default     = 1
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

variable "gateway" {
  description = "The gateway where traffic will be aggregated"
  type        = string
  default     = "10.88.10.254"
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
// -------------------------------------------------- //
