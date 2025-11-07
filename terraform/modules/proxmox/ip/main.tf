locals {
  ipconfigs = [
    for network in var.networks: flatten([
      for i in range(0, var.metric) : [
        format(
          "ip=${network.ip_range}/${network.netmask.short},gw=${network.gateway}", 
          network.ip_beg + i * network.proxmox.cluster.size + network.proxmox.cluster.id,
        )
      ]
    ])
  ]

  ip_list = [
    for network in var.networks: flatten([
      for i in range(0, var.metric) : [
        format(
          "${network.ip_range}", 
          network.ip_beg + i * network.proxmox.cluster.size + network.proxmox.cluster.id,
        )
      ]
    ])
  ]
}
