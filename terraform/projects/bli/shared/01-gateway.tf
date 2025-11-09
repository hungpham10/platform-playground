module "gateway-inventory" {
  source     = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/inventory?ref=main"
  role       = "gateway"
  net        = "gw"
  name       = "gateway"
  node_type  = "vm"
  metric     = var.gateway.metric
  interfaces = module.ip-gateway-internet.interfaces
}

module "ip-gateway-internet" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.gateway.metric
  proxmox  = var.proxmox
  networks  = [{
    bridge   = var.internet.bridge
    iface    = var.ifaces[0]
    gateway  = var.internet.gateway
    ip_range = var.internet.ip_range
    ip_beg   = var.gateway.ip_beg.internet
    ip_end   = var.gateway.ip_end.internet
    netmask  = var.internet.netmask
    routes   = var.internet.routes
  }]
}

module "gateway" {
  source          = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=main"
  name            = "${var.name}-gateway"
  bastion         = var.bastion
  proxmox         = var.proxmox
  vmid            = var.vmid
  partition       = var.gateway.partition
  total_partition = var.total_partition
  node_type       = "vm"
  topdir          = path.module
  playbook        = "gateway"
  metric          = var.gateway.metric
  cpu             = var.gateway.cpu
  memory          = var.gateway.memory
  disks           = var.gateway.disks
  gateway         = var.internet.gateway
  networks        = module.ip-gateway-internet.networks
  inventory       = module.gateway-inventory.inventory
  flags           = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
  }
}

