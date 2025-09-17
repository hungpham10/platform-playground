resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = var.pool.id
  display_name              = var.pool.name
  description               = var.pool.description
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC Provider"

  oidc {
    issuer_uri = var.pool.issuer
  }

  attribute_mapping = var.pool.filters
}
