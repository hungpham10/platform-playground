output "disks" {
  value = length(var.disks) > 0? "${data.google_compute_disk.disks.*.id}": "${google_compute_disk.disks.*.id}"
}

output "snapshots" {
  value = var.take_snapshots? "${google_compute_snapshot.snapshots.*.id}": []
}

output "properties" {
  value = [
    for disk in data.google_compute_disk.disks: {
      id       = disk.id
      name     = disk.name
      zone     = disk.zone
      size     = disk.size
      image    = disk.image
      snapshot = disk.snapshot

      opt = {
        physical_block_size_bytes = disk.physical_block_size_bytes
      }
    }
  ]
}
