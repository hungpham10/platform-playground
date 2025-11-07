module "gateway" {
  source             = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=main"
  name               = "${var.name}-gateway"
  bastion            = var.bastion
  proxmox            = var.proxmox
  debug              = var.debug
  vmid               = var.vmid
  repository         = var.repository
  playbook           = var.playbooks.gateway
  partition          = var.gateway.partition
  total_partition    = var.total_partition
  vault              = var.vault
  telegram           = var.telegram
  promtail           = var.promtail
  node_type          = "vm"
  topdir             = path.module

  metric   = 2
  cpu      = var.gateway.cpu
  memory   = var.gateway.memory
  disks    = var.gateway.disks
  gateway  = var.internet.gateway
  flags    = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
  }
  networks = [
    {
      # @NOTE: internet
      bridge   = var.internet.bridge
      iface    = var.ifaces[0]
      gateway  = var.internet.gateway
      ip_range = var.internet.ip_range
      ip_beg   = var.gateway.ip_beg.internet
      ip_end   = var.gateway.ip_end.internet
      routes   = var.internet.routes
    },
    {
      # @NOTE: internal
      bridge   = var.internal.bridge
      iface    = var.ifaces[1]
      gateway  = var.internal.gateway
      ip_range = var.internal.ip_range
      ip_beg   = var.gateway.ip_beg.internal
      ip_end   = var.gateway.ip_end.internal
      routes   = var.internal.routes
    },
  ]

  infrastructure_config_map = <<-EOF
EOF
}

