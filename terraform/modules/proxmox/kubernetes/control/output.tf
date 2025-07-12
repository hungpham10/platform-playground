output "masters" {
  description = "Define master's inventory"
  value = [
    for i in range(0, local.metric_master) :
    format(var.networks[0].ip_range, var.networks[0].ip_beg + i)
  ]
}

output "workers" {
  description = "Define workers's inventory"
  value = {
    groups = ["k8s-worker-[1:${var.metric.worker}]"]
    ip     = var.kubernetes.workers.ip
    names  = module.k8s-worker.workers.names
    disks = concat(
      var.kubernetes.workers.disks,
      [
        for i in range(0, local.metric_worker) :
        var.disks.worker
      ]
    )
  }
}

output "cidr_range" {
  description = "The range of ip which will be used by k8s master to configure container network"
  value       = var.cidr_range
}

output "kubeconfig_yaml_content" {
  description = "the kubeconfig which will be used to access from internal"
  value       = var.flags.enable_notify_when_done ? yamldecode(data.remote_file.get_master_kuberconfig[0].content) : ""
}

output "client_certificate" {
  description = "the client certificate"
  value       = var.flags.enable_notify_when_done ? base64decode(local.kubeconfig_yaml_content.users[0].user.client-certificate-data) : ""
}

output "client_key" {
  description = "the client key"
  value       = var.flags.enable_notify_when_done ? base64decode(local.kubeconfig_yaml_content.users[0].user.client-key-data) : ""
}

output "cluster_ca_certificate" {
  description = "the cluster ca certificate"
  value       = var.flags.enable_notify_when_done ? base64decode(local.kubeconfig_yaml_content.clusters[0].cluster.certificate-authority-data) : ""
}

output "host" {
  description = "the endpoint to access kubeapi-server"
  value = var.flags.enable_notify_when_done ? (
    length(local.networks.master) > 0 ? (
      format("https://${local.networks.master[0].ip_range}:6443", local.networks.master[0].ip_beg)
      ) : (
      local.kubeconfig_yaml_content.clusters[0].cluster.server
    )
  ) : ""
}
