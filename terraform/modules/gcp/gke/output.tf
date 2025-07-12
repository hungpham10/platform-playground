output "cluster_name" {
  description = "The cluster name which is used to identify when use with kubernetes/helm providers"
  value       = "gke-${var.gcp.project_id}-${var.name}"
}

output "location" {
  description = "The cluster's location "
  value       = var.region
}

output "endpoint" {
  description = "The GKE endpoint which will be used to pass directly to another module"
  value       = google_container_cluster.kubernetes.endpoint
}

output "cluster_ca_certificate" {
  description = "The GKE cluster CA certificate"
  value       = google_container_cluster.kubernetes.master_auth.0.cluster_ca_certificate
}

output "objects" {
  value = flatten([
    google_container_cluster.kubernetes,
    google_container_node_pool.preemptible_nodepool,
    google_container_node_pool.regular_nodepool
  ])
}
