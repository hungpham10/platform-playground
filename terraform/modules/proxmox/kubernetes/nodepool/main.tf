
terraform {
  required_version = ">= 1.0.0"
}

locals {
  node_type = var.node_type != "worker" && length(var.node_type) > 0 ? "worker-${var.node_type}" : "worker"
}

module "node-pool" {
  source                 = "../../node"
  topdir                 = var.topdir
  node_type              = local.node_type
  format                 = "k8s"
  vmid                   = var.vmid
  layer                  = var.layer
  partition              = var.partition
  total_partition        = var.total_partition
  username               = var.username
  password               = var.password
  name                   = var.name
  proxmox                = var.proxmox
  metric                 = var.metric
  iothread               = var.iothread
  template               = var.template
  cpu                    = var.cpu
  socket                 = var.socket
  memory                 = var.memory
  disks                  = var.disks
  debug                  = var.debug
  opts                   = var.opts
  networks               = var.networks
  netmask                = var.netmask
  gateway                = var.gateway
  repository             = var.repository
  branch                 = var.branch
  playbook               = var.playbook
  telegram               = var.telegram
  promtail               = var.promtail
  tls_key                = var.tls_key
  flags = {
    use_notify_when_done     = false
    use_statefulset_strategy = false
    use_agent                = var.flags.use_agent
    enable_elastic_network   = var.flags.enable_elastic_network
  }
  instruction_folder        = var.instruction_folder
  infrastructure_config_map = var.infrastructure_config_map
}
