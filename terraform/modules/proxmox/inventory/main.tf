locals {
  instances = flatten([
    for i in range(0, var.metric): [
      "${var.node_type}-${var.name}-${i + 1}"
    ]
  ])

  inventory = {
    all = {
      hosts = {
        for i in range(0, var.metric) : local.instances[i] => merge(
          {
            ansible_host            = join("", var.interfaces[i][0].addresses)
            ansible_user            = module.env.username
            ansible_password        = module.env.password
            instance_role           = var.role
            net                     = var.net
            domain                  = local.instances[i]
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

