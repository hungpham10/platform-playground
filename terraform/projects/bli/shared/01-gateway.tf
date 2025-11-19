module "gateway-inventory" {
  source     = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/inventory?ref=3-fix-issue-teraform-module-using-wrong-name"
  net        = "gw"
  name       = var.name
  node_type  = "gateway"
  metric     = var.gateway.metric
  interfaces = module.ip-gateway-internet.interfaces
}

module "ip-gateway-internet" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=3-fix-issue-teraform-module-using-wrong-name"
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
  source          = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=3-fix-issue-teraform-module-using-wrong-name"
  name            = var.name
  bastion         = var.bastion
  proxmox         = var.proxmox
  vmid            = var.vmid
  partition       = var.gateway.partition
  total_partition = var.total_partition
  node_type       = "gateway"
  topdir          = path.module
  playbook        = "playbooks/setup/gateway.yml"
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

