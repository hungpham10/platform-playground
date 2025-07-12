variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}

variable "node_pool" {
  description = "The node pool configuration"
  type        = object({
    zones:        list(string)
    metric:       object({
      preemptible: number
      regular:     number
    })
    machine_type: object({
      preemptible: string
      regular:     string
    })
  })
  default     = {
    zones         = ["asia-east1-b", "asia-east1-c"]
    metric        = {
      preemptible = 1
      regular     = 0
    }
    machine_type  = {
      preemptible = "n1-standard-4"
      regular     = "t2d-standard-4"
    }
  }
}

variable "node_version" {
  description = "The kubernetes version"
  type        = string
  default     = null
}

variable "name" {
  description = "The cluster name"
  type        = string
  default     = ""
}

variable "region" {
  description = "The location where to put master nodes"
  type        = string
  default     = "asia-east1"
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

variable "logging_service" {
  description = "The Google cloud platform logging service"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "The Google cloud platform monitoring service"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "initial_node_count" {
  description = "The number of node will be initialized as the becoming resource"
  type        = object({
    preemptible: number
    regular:     number
  })
  default     = {
    preemptible = 0
    regular     = 0
  }
}

variable "cluster_telemetry" {
  description = "Whether or not integrating cluster with telemetry service"
  type        = string
  default     = "DISABLE"
}

variable "horizontal_pod_autoscaling" {
  description = "Whether or not enable pod autoscaling"
  type        = bool
  default     = true
}

variable "http_load_balancing" {
  description = "Whether or not enable http load balancer"
  type        = bool
  default     = true
}

variable "network_policy_config" {
  description = "Whether or not enable network policy for GKE master nodes"
  type        = bool
  default     = true
}

variable "gcp_filestore_csi_driver_config" {
  description = "Whether or not using filestore as CSI driver to provide kubernetes's volumes"
  type        = bool
  default     = false
}

variable "gce_persistent_disk_csi_driver_config" {
  description = "Whether or not using gce as persistent storage for CSI driver"
  type        = bool
  default     = false
}

variable "vertical_pod_autoscaling" {
  description = "Whether or not autoscale pod vertically"
  type        = bool
  default     = false
}

variable "dns_cache_config" {
  description = "Whether or not configuring dns cache for each nodes within this cluster"
  type        = bool
  default     = false
}

variable "autoscale" {
  description = "Configure the cluster autoscaling"
  type        = object({
    enabled: bool
  })
  default     = {
    enabled = false
  }
}

variable "resource_limits" {
  description = "Configure resource limitations so the GKE could know when to auto triggering node scaling"
  type        = list(object({
    resource_type: string
    minimum:       number
    maximum:       number
  }))
  default     = [{
    resource_type = "cpu"
    minimum       = "1"
    maximum       = "64"
  },
  {
    resource_type = "ram"
    minimum       = "1"
    maximum       = "256"
  }]
}

variable "location_policy" {
  description = "Location policy specifies the algorithm used when scaling-up the node pool"
  type        = object({
    preemptible: string
    regular:     string
  })
  default     = {
    preemptible = "ANY"
    regular     = "ANY"
  }
}

variable "min_node_count" {
  description = "Minimum number of node to be presented per availablity zone"
  type        = object({
    preemptible: number
    regular:     number
  })
  default     = {
    preemptible: 1
    regular:     1
  }
}

variable "total_min_node_count" {
  description = "Minimum number of node to be presented within the cluster"
  type        = object({
    preemptible: number
    regular:     number
  })
  default     = {
    preemptible: 1
    regular:     1
  }
}

variable "max_node_count" {
  description = "Maximum number of node to be presented per availablity zone"
  type        = object({
    preemptible: number
    regular:     number
  })
  default     = {
    preemptible: 1
    regular:     1
  }
}

variable "total_max_node_count" {
  description = "Maximum number of node to be presented within the cluster"
  type        = object({
    preemptible: number
    regular:     number
  })
  default     = {
    preemptible: 1
    regular:     1
  }
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
