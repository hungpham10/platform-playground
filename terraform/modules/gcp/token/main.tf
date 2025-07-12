provider "google-beta" {
  alias  = "tokengen"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

data "google_client_config" "default" {
  provider = google-beta.tokengen
}

data "google_service_account_access_token" "sa" {
  provider               = google-beta.tokengen
  target_service_account = "${var.gcp.service_account}"

  lifetime               = "1800s"
  scopes                 = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

