provider "google-beta" {
  alias = "tokengen"
}

data "google_client_config" "default" {
  provider = google.tokengen
}

data "google_service_account_access_token" "sa" {
  provider               = google.tokengen
  target_service_account = "${var.gcp.service_account}"

  lifetime               = "600s"
  scopes                 = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

provider "google" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = data.google_service_account_access_token.sa.access_token
  request_timeout = "60s"
}

resource "google_project_iam_member" "all_project_group_member" {
  project  = var.gcp.project_id
  for_each = toset(var.project_group_members)
  role     = each.value.role
  member   = format("%s%s", "group:", each.value.groups)
}

resource "google_service_account" "all_service_account" {
  project      = var.gcp.project_id
  for_each     = toset(var.service_accounts)
  account_id   = each.value.id
  display_name = each.value.name
  disabled     = each.value.disabled
}

locals {
  service_account_iam_pairs = flatten([
    for sa, bindings in var.service_account_bindings : [
      for binding in bindings : {
        service_account = sa
        role            = binding.role
        member          = binding.member
      }
    ]
  ])
}

resource "google_service_account_iam_member" "all_service_account_iam_member" {
  for_each = { for idx, b in local.service_account_iam_pairs : "${b.service_account}-${b.role}-${b.member}" => b }

  service_account_id = "projects/${var.gcp.project_id}/serviceAccounts/${each.value.service_account}"
  role               = each.value.role
  member             = each.value.member
}
