variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}

variable "status" {
  description = "The status of instances"
  type        = bool
  default     = true
}

variable "is_mocking" {
  description = "This flag is used to configure whether or not this module will be used to mock with data of existence instances"
  type        = bool
  default     = false
}

variable "configs" {
  description = "The configuration of each instance"
  default     = []
}

variable "name" {
  description = "The custom project name which is used when we share gcp project with another teams"
  type        = string
  default     = ""
}

variable "metric" {
  description = "How many instance will be spare with this configuration?"
  type        = number
  default     = 0
}

variable "format" {
  description = "The node format which is used to define which kind of resource would be"
  type        = string
  default     = "vm"
}

variable "node_type" {
  description = "The node type which is pointing out which kind of component we ought to be installing on this"
  type        = string
  default     = "generic"
}

variable "machine_type" {
  description = "The machine type which define specific the intention of this instance so gcp could choose the best machine configuration"
  type        = string
  default     = "n2d-standard-4"
}

variable "min_cpu_platform" {
  description = "The node type which is pointing out which kind of component we ought to be installing on this"
  type        = string
  default     = "generic"
}

variable "zone" {
  description = "The zone where the instance will be located"
  type        = string
  default     = "asia-east1-b"
}

variable "tags" {
  description = "The network tags which define which instances can reach this one"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "Define the behavior when terraform try to destroy the instance"
  type        = bool
  default     = false
}

variable "allow_stopping_for_update" {
  description = "Define the behavior whether or not we could stop instance to update"
  type        = bool
  default     = false
}

variable "preemptible" {
  description = "Define this instance would be preemptible or not"
  type        = bool
  default     = true
}

variable "provisioning" {
  description = "Define this instance could be provisioning with specific gcp mode"
  type        = string
  default     = "SPOT"
}

variable "maintenance" {
  description = "Define the maintenance behavious for each instance"
  type        = string
  default     = "TERMINATE"
}

variable "is_immutable" {
  description = "The node type which is pointing out which kind of component we ought to be installing on this"
  type        = bool
  default     = false
}

variable "network" {
  description = "The name or self_link of the network to attach this interface to"
  type        = string
  default     = ""
}

variable "subnetwork" {
  description = "The subnetwork must exist in the same region this instance will be created in, and will be use if network isn't defined"
  default     = []
}

variable "ip_range" {
  description = "The IP range where all node will be assign using these"
  type        = list(object({
    format: string
    begin:  number
    end:    number
  }))
  default     = [{
    format:  "10.88.10.%d"
    begin:   20
    end:     20
  }]
}

variable "boot_disk" {
  description = "The disk configuration for each instance"
  type        = object({
    auto_delete: bool
    image:       string
    size:        number
    mode:        string
    name:        string
    source:      string
  })
  default     = {
    image       = "centos-6-v20180104"
    size        = 10
    source      = ""
    auto_delete = true
    mode        = "READ_WRITE"
    name        = "default"
  }
}

variable "attached_disks" {
  description = "The definition of disks which are used to attach to instances"
  type        = list(object({
    name: string
  }))
  default     = []
}

variable "members" {
  description = "The list of member who can access the instances"
  type        = list(string)
  default     = []
}

variable "groups" {
  description = "The list of group who can access the instances"
  type        = list(string)
  default     = []
}

variable "service_accounts" {
  description = "The definition of service account which have been grant to access these instances"
  type        = list(object({
    email: string
  }))
  default     = []
}

variable "named_ports" {
  description = "Mapping name and port number"
  type        = list(object({
    name: string
    port: number
  }))
  default     = []
}

variable "gcp" {
  description = "The gcp configuration for specific project"
  type        = object({
    service_account: string
    project_id:      string
    region:          string
    zone:            string
  })
}

variable "flags" {
  description = "The list of flags which will be used for these instances"
  type        = object({
    enable_iap_tunnel: bool
  })
  default     = {
    enable_iap_tunnel = false
  }
}

variable "repository" {
  description = "The ansible repository where is located playbooks to provision nodes"
  type        = string
  default     = ""
}

variable "branch" {
  description = "The ansible repository's branch where is located playbooks to provision nodes"
  type        = string
  default     = "main"
}

variable "playbook" {
  description = "The ansible playbook which is used to provision nodes"
  type        = string
  default     = ""
}

variable "user_script" {
  description = "The user script which will be used to call for troubleshooting or doing some specific things"
  type        = string
  default     = ""
}

variable "ansible_host_lines" {
  description = "The ansible hosts which has been defined list of hosts and they are compressed as a string"
  type        = string
  default     = ""
}

variable "ansible_host_group" {
  description = "The ansible host groups which has been definedlist of specific groups for component and they are compressed as a string"
  type        = string
  default     = ""
}

variable "ansible_extra_vars" {
  description = "The ansible extra vars which has been shared among ansible hosts"
  type        = string
  default     = ""
}

variable "ansible_config_map" {
	description = "The ansible config map which is used to custom nodes automatically"
	type        = object({
    data: string
    path: string
  })
	default     = {
    data = ""
    path = ""
  }
}
