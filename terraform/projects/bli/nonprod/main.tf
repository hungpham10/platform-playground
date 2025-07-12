module "gateway" {
  source             = "../modules/proxmox/node"
  name               = "${var.name}-gateway"
  bastion            = var.bastion
  proxmox            = var.proxmox
  debug              = var.debug
  vmid               = var.vmid
  repository         = var.repository
  topdir             = path.module
  playbook           = "gateway"
  node_type          = "gateway"
  partition          = 0
  total_partition    = var.total_partition
  vault              = var.vault
  telegram           = var.telegram
  promtail           = var.promtail
  instruction_folder = var.instruction_folder

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
      iface    = "ens19"
      gateway  = var.internet.gateway
      ip_range = var.internet.ip_range
      ip_beg   = var.gateway.ip_beg.internet
      ip_end   = var.gateway.ip_end.internet
      routes   = var.internet.routes
    },
    {
      # @NOTE: internal
      bridge   = var.internal.bridge
      iface    = "ens20"
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

module "database" {
  source             = "../modules/proxmox/node"
  name               = "${var.name}-database"
  bastion            = var.bastion
  proxmox            = var.proxmox
  vmid               = var.vmid
  debug              = var.debug
  repository         = var.repository
  topdir             = path.module
  playbook           = "database"
  node_type          = "vm"
  partition          = 1
  total_partition    = var.total_partition
  vault              = var.vault
  telegram           = var.telegram
  promtail           = var.promtail
  instruction_folder = var.instruction_folder

  metric   = var.database.metric
  cpu      = var.database.cpu
  memory   = var.database.memory
  disks    = var.database.disks
  flags    = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = true
  }
  networks = [
    {
      # @NOTE: internal
      bridge   = var.internal.bridge
      iface    = "ens19"
      gateway  = module.gateway.ip_list[0]
      ip_range = var.internal.ip_range
      ip_beg   = var.database.ip_beg.internal
      ip_end   = var.database.ip_end.internal
      routes   = var.internal.routes
    },
  ]

  infrastructure_config_map = <<-EOF
EOF
}

module "control" {
  source             = "../modules/proxmox/kubernetes/control"
  name               = "${var.name}-control"
  proxmox            = var.proxmox
  vmid               = var.vmid
  repository         = var.repository
  branch             = var.branch
  debug              = var.debug
  playbook           = "kubernetes"
  topdir             = path.module
  partition          = 2
  total_partition    = var.total_partition
  vault              = var.vault
  telegram           = var.telegram
  promtail           = var.promtail
  prometheus         = var.prometheus
  instruction_folder = var.instruction_folder

  control_plan_ip = var.control.control_plan_ip
  coredns_ip      = var.control.coredns_ip
  cidr_range      = var.control.cidr_range
  lb_range        = var.control.lb_range
  metric          = var.control.metric
  cpu             = var.control.cpu
  memory          = var.control.memory
  disks           = var.control.disks
  networks        = [
    {
      # @NOTE: internal
      bridge   = var.internal.bridge
      iface    = "ens19"
      gateway  = module.gateway.ip_list[0]
      ip_range = var.internal.ip_range
      ip_beg   = var.control.ip_beg.internal
      ip_end   = var.control.ip_end.internal
      routes   = var.internal.routes
    },
    {
      # @NOTE: ilb
      bridge   = var.ilb.bridge
      iface    = "ens20"
      gateway  = module.gateway.ip_list[1]
      ip_range = var.ilb.ip_range
      ip_beg   = var.control.ip_beg.ilb
      ip_end   = var.control.ip_end.ilb
      routes   = var.ilb.routes
    }
  ]

  infrastructure_config_map = <<-EOF
EOF
}

