provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "60s"
}

locals {
  project_id = length(var.name) > 0? var.name: var.gcp.project_id
  
  private_cidr = flatten([
    for l, cidr_range in var.cidr_range: [
      for id in range(cidr_range.private.begin, cidr_range.private.end): {
        cidr = format("${cidr_range.private.range}", id)
        name = length(var.subnet.privates) > 0? var.subnet.privates[id - cidr_range.private.begin]: "subnet-${local.project_id}-private-${l + 1}-${id - cidr_range.private.begin + 1}"
      }
    ]
  ])

  public_cidr = flatten([
    for l, cidr_range in var.cidr_range: [
      for id in range(cidr_range.public.begin, cidr_range.public.end): {
        cidr = format("${cidr_range.public.range}", id)
        name = length(var.subnet.publics) > 0? var.subnet.publics[id - cidr_range.public.begin]: "subnet-${local.project_id}-public-${l + 1}-${id - cidr_range.public.begin + 1}"
      }
    ]
  ])
}

data "google_compute_network" "vpc" {
  count   = var.is_mocking? 1: 0
  project = var.gcp.project_id
  name    = var.name
}

data "google_compute_subnetwork" "subnetwork" {
  count   = var.is_mocking? length(var.subnet.publics) + length(var.subnet.privates): 0
  name    = count.index < length(var.subnet.publics)? var.subnet.publics[count.index]: var.subnet.privates[count.index - length(var.subnet.publics)]
}

resource "google_compute_network" "vpc" {
  count   = var.is_mocking? 0: 1
  project = var.gcp.project_id
  name    = "vpc-${local.project_id}"
  auto_create_subnetworks = "${var.auto_create_subnetworks}"
}

resource "google_compute_subnetwork" "public" {
  count         = var.is_mocking? 0: length(local.public_cidr)
  name          = local.public_cidr[count.index].name
  region        = var.region
  network       = google_compute_network.vpc[0].name
  project       = var.gcp.project_id
  ip_cidr_range = local.public_cidr[count.index].cidr
}

resource "google_compute_subnetwork" "private" {
  count                    = var.is_mocking? 0: length(local.private_cidr)
  name                     = local.private_cidr[count.index].name
  project                  = var.gcp.project_id
  private_ip_google_access = true
  region                   = var.region
  network                  = google_compute_network.vpc[0].name
  ip_cidr_range            = local.private_cidr[count.index].cidr
}
