module "kubernetes-master-inventory" {
  source     = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/inventory?ref=main"
  net        = "k8s"
  name       = var.name
  node_type  = "kubernetes"
  metric     = var.kubernetes.master.metric
  interfaces = module.ip-kubernetes-master-internet.interfaces
  variables  = {
    subdomain_instance_role = "master"
    k8s_pod_cidr            = "10.1.0.0/16"
    k8s_service_cidr        = "132.10.12.0/24"
  }
}

module "ip-kubernetes-master-internet" {
  source   = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/ip?ref=main"
  metric   = var.kubernetes.master.metric
  proxmox  = var.proxmox
  networks  = [{
    bridge   = var.internet.bridge
    iface    = var.ifaces[0]
    gateway  = var.internet.gateway
    ip_range = var.internet.ip_range
    ip_beg   = var.kubernetes.master.ip_beg.internet
    ip_end   = var.kubernetes.master.ip_end.internet
    netmask  = var.internet.netmask
    routes   = var.internet.routes
  }]
}

module "kubernetes-master" {
  source          = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/proxmox/node?ref=main"
  name            = var.name
  bastion         = var.bastion
  proxmox         = var.proxmox
  vmid            = var.vmid
  partition       = var.kubernetes.master.partition
  total_partition = var.total_partition
  node_type       = "kubernetes"
  topdir          = path.module
  playbook        = "playbooks/setup/kubernetes/master.yml"
  metric          = var.kubernetes.master.metric
  cpu             = var.kubernetes.master.cpu
  memory          = var.kubernetes.master.memory
  disks           = var.kubernetes.master.disks
  gateway         = var.internet.gateway
  networks        = module.ip-kubernetes-master-internet.networks
  inventory       = module.kubernetes-master-inventory.inventory
  flags           = {
    use_notify_when_done     = true
    use_elastic_network      = false
    use_agent                = false
    use_statefulset_strategy = false
  }
}

