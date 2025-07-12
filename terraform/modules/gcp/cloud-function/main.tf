provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "600s"
}

resource "google_cloudfunctions_function" "function" {
  name        = var.name
  lables      = var.lables
  runtime     = var.runtime
  description = "${var.ticket}: ${var.description}"

  available_memory_mb   = var.memory
  source_archive_bucket = var.bucket
  source_archive_object = var.archive
  trigger_http          = true
  entry_point           = "helloGET"

  environment_variables        = var.variables.env
  build_environment_variables  = var.variables.build
  secret_environment_variables = var.variables.secret
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  for_each       = to_set(var.invokers)

  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = each.key
}
