provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "60s"
}

locals {
  project_id = length(var.name) > 0? var.name: var.gcp.project_id
}

#data "google_container_attached_versions" "versions" {
#  location = var.region
#  project  = var.gcp.project_id
#}

resource "google_container_cluster" "kubernetes" {
  name    = "gke-${var.gcp.project_id}-${var.name}"
  project = var.gcp.project_id

  # @NOTE: whether or not we will delete default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  # @NOTE: configure where to locate nodes within google cloud platform
  location       = var.region
  node_locations = var.node_pool.zones

  # @NOTE: configure network for each gke cluster
  network    = var.network
  subnetwork = var.subnetwork

  # @NOTE: configure monitoring system
  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  # @NOTE: cluster addons configuration
  addons_config {
    horizontal_pod_autoscaling {
      disabled = !var.horizontal_pod_autoscaling
    }

    http_load_balancing {
      disabled = !var.http_load_balancing
    }

    network_policy_config {
      disabled = !var.network_policy_config
    }

    gcp_filestore_csi_driver_config {
      enabled = var.gcp_filestore_csi_driver_config
    }

    dns_cache_config {
      enabled = var.dns_cache_config
    }
  }

  # @NOTE: cluster autoscaling configuration
  cluster_autoscaling {
    enabled           = var.autoscale.enabled

    dynamic "resource_limits" {
      for_each = var.autoscale.enabled? var.resource_limits: []

      content {
        resource_type = resource_limits.value.resource_type
        minimum       = resource_limits.value.minimum
        maximum       = resource_limits.value.maximum
      }
    }
  }

  # @NOTE: configure to adjust pod resource
  vertical_pod_autoscaling {
    enabled = var.vertical_pod_autoscaling
  }

  release_channel {
    channel = (var.node_version == null || length(var.node_version) == 0)? "RAPID": "UNSPECIFIED"
  }

  # @NOTE: configure private cluster
  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "${ var.gke_master_ipv4_cidr_block }"
  }

  # @NOTE: setup master authentication
  master_auth {
    username = ""
    password = "" #empty -> disable basic auth

    client_certificate_config {
      issue_client_certificate = "${var.issue_client_certificate}"
    }
  }
}

resource "google_container_node_pool" "preemptible_nodepool" {
  count    = var.node_pool.metric.preemptible
  name     = "node-pool-${var.name}-preemp-${count.index}"
  cluster  = google_container_cluster.kubernetes.name
  project  = var.gcp.project_id
  location = var.region

  # @NOTE: multiple zone which will be use to increase high availability
  node_locations = var.node_pool.zones

  # @NOTE: configure number of node will be allocated
  initial_node_count = var.initial_node_count.preemptible

  # @NOTE: autoscaling configuration
  autoscaling {
    #location_policy      = var.location_policy.preemptible
    min_node_count       = var.min_node_count.preemptible
    max_node_count       = var.max_node_count.preemptible
    total_min_node_count = var.min_node_count.preemptible > 0? 0: var.total_min_node_count.preemptible
    total_max_node_count = var.max_node_count.preemptible > 0? 0: var.total_max_node_count.preemptible
  }

  # @NOTE: node configuration
  node_config {
    preemptible  = true
    machine_type = var.node_pool.machine_type.preemptible
  }

  # # @NOTE: notification service
  # notification_config {
  #   pubsub {
  #     enabled = var.pubsub_topic != null
  #     topic   = var.pubsub_topic
  #   }
  # }

  version = var.node_version

  # @NOTE: configure node management
  management {
    auto_upgrade = var.node_version == null || length(var.node_version) == 0
    auto_repair  = var.node_version == null || length(var.node_version) == 0
  }
}

resource "google_container_node_pool" "regular_nodepool" {
  count    = var.node_pool.metric.regular
  name     = "node-pool-${var.name}-regular-${count.index}"
  cluster  = google_container_cluster.kubernetes.name
  project  = var.gcp.project_id
  location = var.region

  # @NOTE: multiple zone which will be use to increase high availability
  node_locations = var.node_pool.zones

  # @NOTE: configure number of node will be allocated
  initial_node_count = var.initial_node_count.preemptible

  # @NOTE: autoscaling configuration
  autoscaling {
    #location_policy      = var.location_policy.preemptible
    min_node_count       = var.min_node_count.preemptible
    max_node_count       = var.max_node_count.preemptible
    total_min_node_count = var.min_node_count.preemptible > 0? 0: var.total_min_node_count.preemptible
    total_max_node_count = var.max_node_count.preemptible > 0? 0: var.total_max_node_count.preemptible
  }

  # @NOTE: node configuration
  node_config {
    preemptible  = false
    machine_type = var.node_pool.machine_type.regular
  }

  # # @NOTE: notification service
  # notification_config {
  #   pubsub {
  #     enabled = var.pubsub_topic != null
  #     topic   = var.pubsub_topic
  #   }
  # }

  version = var.node_version

  # @NOTE: configure node management
  management {
    auto_upgrade = var.node_version == null || length(var.node_version) == 0
    auto_repair  = var.node_version == null || length(var.node_version) == 0
  }
}
