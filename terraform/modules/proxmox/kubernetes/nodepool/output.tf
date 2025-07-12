output "masters" {
  description = "Define master's inventory"
  value       = var.kubernetes.masters
}

output "workers" {
  description = "Define workers's inventory"
  value = {
    groups = concat(var.kubernetes.workers.groups, ["k8s-${var.node_type}-[1:${var.metric}]"])
    kinds  = concat(var.kubernetes.workers.kinds, ["${var.node_type} ${var.metric}"])
    names = concat(var.kubernetes.workers.names, [
      for i in range(0, var.metric) :
      "k8s-${local.node_type}-${i}"
    ])
    disks = concat(
      var.kubernetes.workers.disks,
      [
        for i in range(0, var.metric) :
        var.disks
      ]
    )
  }
}
