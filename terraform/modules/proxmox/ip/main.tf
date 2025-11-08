locals {
  ipconfigs = [
    for i in range(0, var.metric) : flatten([
      for network in var.networks: [
        format(
          "ip=${network.ip_range}/${var.netmask.short},gw=${network.gateway}", 
          network.ip_beg + i * var.proxmox.cluster.size + var.proxmox.cluster.id,
        )
      ]
    ])
  ]

  ip_list = [
    for i in range(0, var.metric) : flatten([
      for network in var.networks: [
        format(
          "${network.ip_range}", 
          network.ip_beg + i * var.proxmox.cluster.size + var.proxmox.cluster.id,
        )
      ]
    ])
  ]

  ip_with_netmask_list = [
    for i in range(0, var.metric): flatten([
      for j in range(0, length(var.networks)): [
        "${local.ip_list[i][j]}/${var.netmask.short}"
      ]
    ])
  ]

  interfaces = [
    for i in range(0, var.metric): flatten([
      for j in range(0, length(var.networks)): [
        {
          name        = var.networks[j].iface
          gateway     = var.networks[j].gateway
          nameservers = var.nameservers
          addresses   = [
            local.ip_list[i][j]
          ]
          dhcp        = false
          type        = "ethernet"
        }
      ]
    ])
  ]
}
