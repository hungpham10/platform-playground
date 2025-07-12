
output "id" {
  value = flatten(var.is_mocking? ["${data.google_compute_instance.instance.*.id}"]: ["${google_compute_instance.instance.*.id}"])
}

output "boot_disks" {
  value = flatten(var.is_mocking? ["${data.google_compute_instance.instance.*.boot_disk}"]: ["${google_compute_instance.instance.*.boot_disk}"])
}

output "properties" {
  value = [
    for instance in data.google_compute_instance.instance: {
      id           = instance.id
      name         = instance.name
      description  = instance.description
      machine_type = instance.machine_type
      zone         = instance.zone
      tags         = instance.tags
      status       = instance.current_status == "RUNNING"

      deletion_protection       = instance.deletion_protection
      allow_stopping_for_update = instance.allow_stopping_for_update

      preemptible  = instance.scheduling[0].preemptible
      provisioning = instance.scheduling[0].provisioning_model

      ip         = instance.network_interface[0].network_ip
      network    = instance.network_interface[0].network
      subnetwork = instance.network_interface[0].subnetwork

      image       = instance.boot_disk[0].initialize_params[0].image
      size        = instance.boot_disk[0].initialize_params[0].size
      mode        = instance.boot_disk[0].mode
      source      = instance.boot_disk[0].source
      auto_delete = instance.boot_disk[0].auto_delete
      device_name = instance.boot_disk[0].device_name

      attached_disks = [
        for attached_disk in instance.attached_disk: {
          name        = attached_disk.name
          device_name = attached_disk.device_name
        }
      ]

      service_accounts = [
        for service_account in lookup(instance, "service_accounts", []): {
          email  = service_account.email
          scopes = service_account.scopes
        }
      ]
    }
  ]
}
