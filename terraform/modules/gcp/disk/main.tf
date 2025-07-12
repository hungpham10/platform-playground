provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "600s"
}

data "google_compute_disk" "disks" {
  count   = length(var.disks)
  name    = var.disks[count.index]
  zone    = var.zone
  project = var.gcp.project_id
}

resource "google_compute_disk" "disks" {
  count    = length(var.disks) > 0 || (length(var.snapshot) == 0 && length(var.image) == 0 && length(var.snapshots) == 0)? 0: max(length(var.instances), var.metric)
  name     = "disk-${var.gcp.project_id}-${count.index + 1}"
  type     = var.type
  zone     = var.zone
  size     = var.size
  project  = var.gcp.project_id
  image    = length(var.snapshot) > 0 && length(var.snapshots) > 0? "": var.image
  snapshot = length(var.image) > 0? "": (length(var.snapshots) == 0 || length(var.snapshots[count.index]) == 0? var.snapshot: var.snapshots[count.index])

  # @NOTE: advance configuration
  physical_block_size_bytes = var.opt.physical_block_size_bytes
  provisioned_iops          = var.type != "pd-standard"? var.opt.provisioned_iops: null
}

resource "google_compute_snapshot" "snapshots" {
  count       = var.take_snapshots? (length(var.disks) > 0? length(var.disks): length(var.instances)): 0
  project     = var.gcp.project_id
  name        = "snapshot-${google_compute_disk.disks[count.index].id}"
  source_disk = length(var.disks) > 0? data.google_compute_disk.disks[count.index].id: google_compute_disk.disks[count.index].id
}

resource "google_compute_attached_disk" "attachments" {
  count    = length(var.disks) > 0 && var.metric == 0? 0: length(var.instances)
  disk     = google_compute_disk.disks[count.index].id
  zone     = var.zone
  project  = var.gcp.project_id
  instance = var.instances[count.index]
}
