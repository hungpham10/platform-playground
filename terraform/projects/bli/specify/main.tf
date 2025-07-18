module "database" {
  source             = "../modules/proxmox/node"
  name               = "${var.name}-database"
  bastion            = var.bastion
  proxmox            = var.proxmox
  vmid               = var.vmid
  debug              = var.debug
  repository         = var.repository
  topdir             = path.module
  playbook           = var.playbooks.database
  node_type          = "vm"
  partition          = var.database.partition
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
      iface    = var.ifaces[0]
      gateway  = var.gateway.ip_list[0]
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
  playbook           = var.playbooks.control
  topdir             = path.module
  partition          = var.control.partition
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
      iface    = var.ifaces[0]
      gateway  = var.gateway.ip_list[0]
      ip_range = var.internal.ip_range
      ip_beg   = var.control.ip_beg.internal
      ip_end   = var.control.ip_end.internal
      routes   = var.internal.routes
    },
    {
      # @NOTE: ilb
      bridge   = var.ilb.bridge
      iface    = var.ifaces[1]
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

module "nodepool" {
  source             = "../modules/proxmox/kubernetes/nodepool"
  name               = "${var.name}-nodepool"
  proxmox            = var.proxmox
  vmid               = var.vmid
  repository         = var.repository
  branch             = var.branch
  debug              = var.debug
  playbook           = var.playbook.control
  topdir             = path.module
  partition          = var.control.partition
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
      iface    = var.ifaces[0]
      gateway  = var.gateway.ip_list[0]
      ip_range = var.internal.ip_range
      ip_beg   = var.control.ip_beg.internal
      ip_end   = var.control.ip_end.internal
      routes   = var.internal.routes
    },
    {
      # @NOTE: ilb
      bridge   = var.ilb.bridge
      iface    = var.ifaces[1]
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

