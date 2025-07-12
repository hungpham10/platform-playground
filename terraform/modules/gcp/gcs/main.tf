provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "600s"
}

locals {
  configs = var.configs
}

resource "google_compute_backend_bucket" "public-backend-bucket" {
  provider    = google-beta
  count       = var.feature == "website"? max(length(local.configs), 1): 0
  name        = length(local.configs) > 0? lookup(local.configs[count.index], "backend", "${var.name}-backend"): "${var.name}-backend"
  bucket_name = google_storage_bucket.public-bucket[count.index].name
  enable_cdn  = true
}

resource "google_storage_bucket" "public-bucket" {
  provider  = google-beta
  count     = var.feature == "website"? max(length(local.configs), 1): 0
  name      = length(local.configs) > 0? lookup(local.configs[count.index], "bucket", "${var.name}-bucket"): "${var.name}-bucket"
  labels    = var.labels
  location  = var.location

  force_destroy = var.flags.force_destroy

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["${length(local.configs) > 0? lookup(local.configs[count.index], "origin", var.website.origin): var.website.origin}"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = length(local.configs) > 0? lookup(local.configs[count.index], "max_age", var.website.max_age): var.website.max_age
  }
}

resource "google_storage_default_object_access_control" "public-bucket-read" {
  provider  = google-beta
  count     = var.feature == "website"? max(length(local.configs), 1): 0
  bucket    = google_storage_bucket.public-bucket[count.index].name
  role      = "READER"
  entity    = "allUsers"
}

data "google_compute_global_address" "bucket-lb-ip" {
  provider = google-beta
  count    = var.flags.is_reuse_dns? (var.feature == "website"? max(length(local.configs), 1): 0): 0
  name     = length(local.configs) > 0? lookup(local.configs[count.index], "dns", "${var.name}-dns-zone-${var.level}"): "${var.name}-dns-zone-${var.level}"
}

resource "google_compute_global_address" "bucket-lb-ip" {
  provider = google-beta
  count    = var.feature == "website"? max(length(local.configs), 1): 0
  name     = length(local.configs) > 0? lookup(local.configs[count.index], "lb", "${var.name}-lb"): "${var.name}-lb"
}

data "google_dns_managed_zone" "dns-zone" {
  provider = google-beta
  count    = var.flags.is_reuse_dns? (var.feature == "website"? max(length(local.configs), 1): 0): 0
  name     = lookup(local.configs[count.index], "dns", "${var.name}-dns-zone-${var.level}")
}

resource "google_dns_managed_zone" "dns-zone" {
  provider = google-beta
  count    = var.flags.is_reuse_dns? 0: (var.feature == "website"? max(length(local.configs), 1): 0)
  name     = length(local.configs) > 0? replace(lookup(local.configs[count.index], "zone", "${var.name}-dns-zone-${var.level}"), ".", "-"): "${var.name}-dns-zone-${var.level}"
  dns_name = length(local.configs) > 0? lookup(local.configs[count.index], "zone", "${var.name}.${var.level}."): "${var.organization}.${var.level}."
}

resource "google_dns_record_set" "dns-record" {
  provider     = google-beta
  count        = var.feature == "website"? max(length(local.configs), 1): 0
  name         = "${length(local.configs) > 0? lookup(local.configs[count.index], "record", "${var.name}.${var.organization}.${var.level}"): "${var.name}.${var.organization}.${var.level}"}."
  type         = "A"
  ttl          = length(local.configs) > 0? lookup(local.configs[count.index], "ttl", 300): 300
  managed_zone = var.flags.is_reuse_dns? data.google_dns_managed_zone.dns-zone[count.index].name: google_dns_managed_zone.dns-zone[count.index].name
  rrdatas      = [var.flags.is_reuse_dns? data.google_compute_global_address.bucket-lb-ip[count.index].address: google_compute_global_address.bucket-lb-ip[count.index].address]
}

resource "google_compute_managed_ssl_certificate" "public-cdn-bucket-cert" {
  provider = google-beta
  count    = var.feature == "website"? max(length(local.configs), 1): 0
  name     = length(local.configs) > 0? lookup(local.configs, "cert", "${var.name}-cert"): "${var.name}-cert"
  managed {
    domains = [google_dns_record_set.dns-record[count.index].name]
  }
}

resource "google_compute_url_map" "public-cdn-bucket-url-map" {
  provider        = google-beta
  count           = var.feature == "website"? max(length(local.configs), 1): 0
  name            = length(local.configs) > 0? lookup(local.configs[count.index], "url-map", "${var.name}-url-map"): "${var.name}-url-map"
  default_service = google_compute_backend_bucket.public-backend-bucket[count.index].id
}

resource "google_compute_target_https_proxy" "public-cdn-target-proxy" {
  provider         = google-beta
  count            = var.feature == "website"? max(length(local.configs), 1): 0
  name             = length(local.configs) > 0? lookup(local.configs[count.index], "proxy", "${var.name}-proxy"): "${var.name}-proxy"
  url_map          = google_compute_url_map.public-cdn-bucket-url-map[count.index].id
  ssl_certificates = [google_compute_managed_ssl_certificate.public-cdn-bucket-cert[count.index].id]
}

resource "google_compute_global_forwarding_rule" "default" {
  provider              = google-beta
  count                 = var.feature == "website"? max(length(local.configs), 1): 0
  name                  = "${var.name}-forwarding-rule-${count.index}"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.bucket-lb-ip[count.index].id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.public-cdn-target-proxy[count.index].id
}
