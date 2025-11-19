locals {
  instances = flatten([
    for i in range(0, var.metric): [
      "${var.format}-${var.node_type}-${var.name}-${i + 1}"
    ]
  ])

  inventory = {
    all = {
      hosts = {
        for i in range(0, var.metric) : local.instances[i] => merge(
          {
            ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
            ansible_host            = join("", var.interfaces[i][0].addresses)
            ansible_user            = module.env.username
            instance_role           = var.node_type
            net                     = var.net
            domain                  = format("%s-%s", var.format, local.instances[i])
            network_interfaces      = var.interfaces[i]
          },
          var.variables,
        )
      }
    }
  }
}

module "env" {
  source = "../env"
}

