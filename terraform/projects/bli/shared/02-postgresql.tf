locals {
  postgres_inventory = {
    all = {
      hosts = {
        for i in range(0, var.postgres.metric) : "postgres-${i + 1}" => {
          ansible_host            = join("", module.ip-postgres-internal.ip_list[i])
          ansible_user            = module.env.username
          ansible_password        = module.env.password
          instance_role           = "database"
          net                     = "db"
          domain                  = "vm-postgres-${var.name}-${i + 1}"
          postgres_admin_password = ""
          ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
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
          network_interfaces      = flatten([
            module.ip-postgres-internal.interfaces[i],
          ])
        }
      }
    }
  }
}

module "env" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/env?ref=main"
}

module "ip-postgres-internet" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.postgres.metric
  proxmox  = var.proxmox
  networks  = [{
    bridge   = var.internet.bridge
    iface    = var.ifaces[0]
    gateway  = var.internet.gateway
    ip_range = var.internet.ip_range
    ip_beg   = var.postgres.ip_beg.internet
    ip_end   = var.postgres.ip_end.internet
    netmask  = var.internet.netmask
    routes   = var.internet.routes
  }]
}

module "ip-postgres-internal" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.postgres.metric
  proxmox  = var.proxmox
  networks  = [{
    bridge   = var.internet.bridge
    iface    = var.ifaces[1]
    gateway  = var.internal.gateway
    ip_range = var.internal.ip_range
    ip_beg   = var.postgres.ip_beg.internet
    ip_end   = var.postgres.ip_end.internet
    netmask  = var.internal.netmask
    routes   = var.internal.routes
  }]
}

module "postgres" {
  source             = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=main"
  name               = var.name
  bastion            = var.bastion
  proxmox            = var.proxmox
  vmid               = var.vmid
  partition          = var.postgres.partition
  total_partition    = var.total_partition
  node_type          = "postgres"
  playbook           = "setup/postgres/cluster"
  topdir             = path.module

  metric    = var.postgres.metric
  cpu       = var.postgres.cpu
  memory    = var.postgres.memory
  disks     = var.postgres.disks
  gateway   = var.internet.gateway
  inventory = local.postgres_inventory
  flags     = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
  }
  networks  = flatten([
    module.ip-postgres-internal.networks,
  ])
}

