locals {
  inventory = {
    all = {
      hosts = {
        for i in range(0, var.postgres.metric) : "${var.name}-postgres-${i + 1}" => {
          ansible_host            = module.ip-postgres-internet.ip_list[i]
          ansible_user            = var.username
          ansible_password        = var.password
          instance_role           = "database"
          net                     = "db"
          domain                  = "${var-name}-postgres-${i + 1}"
          postgres_admin_password = ""
          subdomain_instance_role = i == 0 ? "master": "standby"
          postgres_hba_entries    = flatten([
            for j in range(1, var.postgres.metric): [
              {
                type     = "host"
                user     = "replicator"
                method   = "md5"
                database = "replication"
                address  = module.ip-postgres-internet.ip_with_netmask_list[j]
              }
            ]
          ])
          network_interfaces      = [
            module.ip-postgres_hba_entries-internet.network_for_ansible[i],
            module.ip-postgres_hba_entries-internal.network_for_ansible[i],
          ]
        }
      }
    }
  }
}

module "ip-postgres-internet" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.postgres.metric
  bridge   = var.internet.bridge
  iface    = var.ifaces[0]
  gateway  = var.internet.gateway
  ip_range = var.internet.ip_range
  ip_beg   = var.postgres.ip_beg.internet
  ip_end   = var.postgres.ip_end.internet
  netmask  = var.netmask
  routes   = var.internet.routes
}

module "ip-postgres-internal" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.postgres.metric
  bridge   = var.internet.bridge
  iface    = var.ifaces[0]
  gateway  = var.internet.gateway
  ip_range = var.internet.ip_range
  ip_beg   = var.postgres.ip_beg.internet
  ip_end   = var.postgres.ip_end.internet
  netmask  = var.netmask
  routes   = var.internet.routes
}

module "postgres" {
  source             = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=main"
  name               = "${var.name}-postgres"
  bastion            = var.bastion
  proxmox            = var.proxmox
  debug              = var.debug
  vmid               = var.vmid
  repository         = var.repository
  playbook           = var.playbooks.gateway
  partition          = var.postgres.partition
  total_partition    = var.total_partition
  vault              = var.vault
  telegram           = var.telegram
  promtail           = var.promtail
  node_type          = "vm"
  topdir             = path.module

  metric   = var.postgres.metric
  cpu      = var.postgres.cpu
  memory   = var.postgres.memory
  disks    = var.postgres.disks
  gateway  = var.internet.gateway
  flags    = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
  }
  networks = [
    module.ip-postgres-internet.network_for_terraform,
    module.ip-postgres-internal.network_for_terraform,
  ]

  infrastructure_config_map = jsonencode(inventory)
}

