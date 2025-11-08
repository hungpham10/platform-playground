variable "name" {
  description = "The cluster name"
  type        = string
}

variable "username" {
  description = "The default username for the OS"
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
  description = "Feature flags"
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
}

variable "artifact_host" {
  description = "The gitlab host where is storing the ansible repository"
  type        = string
  default     = "gitlab.alpaca.vn"
}

variable "artifact_namespace" {
  description = "The gitlab namespace where is storing the ansible repository"
  type        = string
  default     = "alpaca-projects%2Fdevops"
}

variable "artifact_project" {
  description = "The gitlab project where is storing the ansible repository"
  type        = string
  default     = "alpaca-k8s-inhouse-cluster"
}

variable "project_id" {
  description = "The ansible gitlab project_id repository where is located playbooks to provision nodes"
  type        = string
  default     = "266"
}

variable "access_token" {
  description = "The dedicated access token which will be provided to client as serials to prove license for our products"
  type        = string
}

variable "tag" {
  description = "The ansible repository's branch where which will be used to promote the new infrastructure"
  type        = string
}

variable "playbook" {
  description = "The ansible playbook which is used to provision nodes"
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

variable "inventory" {
  description = "The inventory configuration"
  default     = {}
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

