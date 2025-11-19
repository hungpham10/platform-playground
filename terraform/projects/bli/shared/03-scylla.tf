module "scylla-inventory" {
  source     = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/inventory?ref=main"
  net        = "db"
  name       = var.name
  node_type  = "database"
  metric     = var.scylla.metric
  interfaces = module.ip-scylla-internet.interfaces
}

module "ip-scylla-internet" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.scylla.metric
  proxmox  = var.proxmox
  networks  = [{
    bridge   = var.internet.bridge
    iface    = var.ifaces[0]
    gateway  = var.internet.gateway
    ip_range = var.internet.ip_range
    ip_beg   = var.scylla.ip_beg.internet
    ip_end   = var.scylla.ip_end.internet
    netmask  = var.internet.netmask
    routes   = var.internet.routes
  }]
}

module "scylla" {
  source          = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=main"
  name            = var.name
  bastion         = var.bastion
  proxmox         = var.proxmox
  vmid            = var.vmid
  partition       = var.scylla.partition
  total_partition = var.total_partition
  node_type       = "database"
  template        = "RockyLinuxTemplate"
  topdir          = path.module
  playbook        = "playbooks/setup/scylladb/instance.yml"
  metric          = var.scylla.metric
  cpu             = var.scylla.cpu
  memory          = var.scylla.memory
  disks           = var.scylla.disks
  gateway         = var.internet.gateway
  networks        = module.ip-scylla-internet.networks
  inventory       = module.scylla-inventory.inventory
  flags           = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
  }
}

