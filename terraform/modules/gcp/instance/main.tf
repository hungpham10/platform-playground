provider "google-beta" {
  region          = var.gcp.region
  project         = var.gcp.project_id
  access_token    = var.access_token
  request_timeout = "600s"
}

locals {
  use_instance_group = length(local.configs) > 0? length(setunion(local.configs.*.zone)) == 1: true

  configs = var.configs

  num_of_instances = sum([
    for ip_range in var.ip_range:
      ip_range.end - ip_range.begin
  ])

  ip = flatten([
    for i, ip_range in var.ip_range: [
      for id in range(ip_range.begin, ip_range.end): {
        ip = format(ip_range.format, id)
        subnet = i
      }
    ]
  ])

  metric     = length(local.configs) > 0? length(local.configs): local.num_of_instances
  zone       = length(local.configs) > 0? tolist(setunion(local.configs.*.zone))[0]: var.zone
  project_id = length(var.name) > 0? var.name: var.gcp.project_id

  compute_roles = [
    "roles/compute.viewer",
    "roles/compute.osLogin",
  ]

  snapshots = [
    for i in range(0, local.metric):
      length(data.google_compute_snapshot.boot_snapshots) > 0? (length(data.google_compute_snapshot.boot_snapshots[i].self_link) > 0? data.google_compute_snapshot.boot_snapshots[i].self_link: ""): ""
  ]

  startup_file  = var.install_with_ansible? "${path.module}/scripts/startup/${var.node_type}.sh": "${path.module}/scripts/custom/${var.startup_script}"
  config_file   = fileexists(local.userdata_file)? local.userdata_file: "${path.module}/scripts/startup/generic.sh"
}

module "boot_disks" {
  source       = "../disk"
  gcp          = var.gcp
  zone         = var.zone
  metric       = local.metric
  snapshots    = [
    for i in range(0, (var.is_mocking || length(var.boot_disk.source) == 0? 0: local.metric)):
      data.google_compute_snapshot.boot_snapshots[i].self_link
  ]
  size         = var.boot_disk.size
  access_token = var.access_token
}


data "google_compute_instance" "instance" {
  count = var.is_mocking? length(local.configs): 0
  name  = lookup(local.configs[count.index], "name", "${var.format}-${var.node_type}-${local.project_id}-${count.index + 1}")
  zone  = lookup(local.configs[count.index], "zone", var.zone)
}

resource "google_compute_firewall" "inbound-ip-ssh" {
  name    = "inbound-ip-ssh-of-${var.format}-${var.node_type}-${local.project_id}"
  count   = var.flags.enable_iap_tunnel? 1: 0
  project = var.gcp.project_id
  network = var.network

  direction     = "INGRESS"
  source_ranges = []
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_service_accounts = flatten([
    [
      for sa in (length(local.configs) > 0? lookup(local.configs[count.index], "service_accounts", var.service_accounts): var.service_accounts):
        "${sa.email}"
    ],
    [
      "${var.gcp.service_account}"
    ]
  ])
}

data "google_compute_snapshot" "boot_snapshots" {
  count   = var.is_mocking || length(var.boot_disk.source) == 0? 0: local.metric
  name    = length(local.configs) > 0? lookup(local.configs[count.index], "source"): var.boot_disk.source
  project = var.gcp.project_id
}

resource "google_compute_instance" "instance" {
  count            = var.is_mocking? 0: local.metric

  # @NOTE: configure the common information of each instance
  project          = var.gcp.project_id

  description      = "The instance ${count.index + 1} of ${var.node_type} define as ${var.format} in ${var.gcp.project_id}"
  name             = "${var.format}-${var.node_type}-${local.project_id}-${count.index + 1}"
  machine_type     = length(local.configs) > 0? lookup(local.configs[count.index], "machine_type", var.machine_type): var.machine_type
  #min_cpu_platform = length(local.configs) > 0? lookup(local.configs[count.index], "min_cpu_platform", var.min_cpu_platform): var.min_cpu_platform

  # @NOTE: configure network of this sort of instance which will be share same network
  #        zone and can communicate each other
  zone = length(local.configs) > 0? lookup(local.configs[count.index], "zone", var.zone): var.zone
  tags = length(local.configs) > 0? lookup(local.configs[count.index], "tags", var.tags): var.tags

  # @NOTE: control the status of each instance, it could be RUNNING or TERMINATED
  desired_status = length(local.configs) > 0? lookup(local.configs[count.index], "status", (var.status? "RUNNING": "TERMINATED")): (var.status? "RUNNING": "TERMINATED")

  # @NOTE: some rule of terraform behavior will be set here to apply to instances within this group
  deletion_protection       = var.deletion_protection
  allow_stopping_for_update = var.allow_stopping_for_update

  # @NOTE: configure instance scheduling in which points to the behaviour the gcp will react with
  #        this instance
  scheduling {
    preemptible         = length(local.configs) > 0? lookup(local.configs[count.index], "preemptible", var.preemptible): var.preemptible
    automatic_restart   = !(length(local.configs) > 0? lookup(local.configs[count.index], "preemptible", var.preemptible): var.preemptible)
    provisioning_model  = length(local.configs) > 0? lookup(local.configs[count.index], "provisioning", var.provisioning): var.provisioning
    on_host_maintenance = length(local.configs) > 0? lookup(local.configs[count.index], "maintenance", var.maintenance): var.maintenance

    # @NOTE: is immutable system or not?
    instance_termination_action = var.is_immutable? "DELETE": "STOP"
  }

  # @NOTE: config interface which will be use to communicate between nodes
  network_interface {
    network    = length(local.configs) > 0? lookup(local.configs[count.index], "network", var.network): var.network
    subnetwork = length(local.configs) > 0? lookup(local.configs[count.index], "subnetwork", var.subnetwork[local.ip[count.index].subnet]): var.subnetwork[local.ip[count.index].subnet]
    network_ip = length(local.configs) > 0? lookup(local.configs[count.index], "ip", local.ip[count.index].ip): local.ip[count.index].ip
  }

  # @TODO: store labels in which updated tickets have been approved
  # labels =

  # @NOTE: configure boot disk
  boot_disk {
    dynamic "initialize_params" {
      for_each = toset(length(local.snapshots[count.index]) > 0? []: [{
        image = length(local.configs) > 0? lookup(local.configs[count.index], "image", var.boot_disk.image): var.boot_disk.image
        size  = length(local.configs) > 0? lookup(local.configs[count.index], "size", var.boot_disk.size): var.boot_disk.size
      }])

      content {
        image = initialize_params.key.image
        size  = initialize_params.key.size

        # @TODO: think about how to configure and use labels
        #labels = {
        #}
      }
    }

    # @NOTE: configure disk in case we would like to control disk remotedly like lock/unlock
    #        for maintaining
    auto_delete = length(local.configs) > 0? lookup(local.configs[count.index], "auto_delete", var.boot_disk.auto_delete): var.boot_disk.auto_delete
    device_name = length(local.configs) > 0? lookup(local.configs[count.index], "device_name", var.boot_disk.name): var.boot_disk.name
    mode        = length(local.configs) > 0? lookup(local.configs[count.index], "mode", var.boot_disk.mode): var.boot_disk.mode

    # @NOTE: we could use this one to mock snapshot or using existing disk which are defined
    #        before
    source = length(local.snapshots[count.index]) > 0? module.boot_disks.disks[count.index]: null

  }

  # @NOTE: attach existence disks
  dynamic "attached_disk" {
    for_each = toset([
      for disk in (length(local.configs) > 0? lookup(local.configs[count.index], "attached_disks", var.attached_disks): var.attached_disks):
        {
          name        = disk.name
          device_name = lookup(disk, "device_name", disk.name)
        }
    ])

    content {
      source      = attached_disk.key.name
      device_name = attached_disk.key.device_name
    }
  }

  # @NOTE: service account
  dynamic "service_account" {
    for_each = toset([
      for sa in (length(local.configs) > 0? lookup(local.configs[count.index], "service_accounts", var.service_accounts): var.service_accounts):
        {
          email  = sa.email
          scopes = lookup(sa, "scopes", ["cloud-platform"])
        }
    ])

    content {
      email  = service_account.key.email
      scopes = service_account.key.scopes
    }
  }

  service_account {
    email  = var.gcp.service_account
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = sensitive(templatefile(local.config_file, {
    domain            = "${var.name}"
    size              = "${local.metric}"
    node_type         = "${var.node_type}"
    pubkey            = tls_private_key.internal[0].public_key_openssh)
    privkey           = base64encode(tls_private_key.internal[0].private_key_openssh)
    repository        = "${var.repository}"
    branch            = "${var.branch}"
    playbook          = "${var.playbook}"
    alias             = "${var.ip}"
    id                = "${count.index}"
    ip                = format("${var.ip_range.format}", var.ip_range.begin + count.index)
    commit            = "${local.git.rev}"
    node_type         = "${var.node_type}"
    redis_endpoint    = "${var.redistore.endpoint}"
    redis_port        = "${var.redistore.port}"
    redis_database    = "${var.redistore.database}"
    gateway           = "${var.gateway}"
    debug             = "${var.debug? 1: 0}"
    hostname          = "${var.format}-${var.node_type}-${count.index + 1}"
    username          = "${var.username}"
    password          = "${var.password}"
    notify_when_done  = "${var.debug? 1: 0}"
    monitor           = "${var.debug? 1: 0}"
    user_script       =  join("\n      ", split("\n", var.user_script))
    cluster_size      = "${var.metric}"

    ansible_host_single  = join("\n      ", [
      format("${var.format}-${var.node_type}-%d ansible_host=${var.ip_range.format} ansible_port=22 ansible_user=${var.username} node_id=%d",
             count.index + 1, var.ip_range.begin + count.index, count.index + 1)
    ])

    ansible_host_lines = length(var.ansible_host_lines) > 0? var.ansible_host_lines: "${local.ansible_host_lines}"
    ansible_host_group = "${var.ansible_host_group}"
    ansible_extra_vars = "${local.ansible_extra_vars}"

    ansible_config_map       = "${local.ansible_config_map}"
    ansible_config_yaml_path = "${var.ansible_config_map.path}"

    infrastructure_config_map       = "${local.infrastructure_config_map}"
    infrastructure_config_yaml_path = "${var.infrastructure_config_map.path}"

    telegram_bot_token = "${var.telegram.token}"
    telegram_chat_id   = "${var.telegram.chat_id}"
  }))

  metadata = {
    # @NOTE: force using os-login
    enable-os-login = "true"
  }
}
