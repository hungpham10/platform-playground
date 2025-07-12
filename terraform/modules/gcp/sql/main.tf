provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "60s"
}

locals {
  project_id = length(var.name) > 0? var.name: var.gcp.project_id
}

resource "google_sql_database" "database" {
  name = "sql-${var.gcp.project_id}-${var.name}"
}
