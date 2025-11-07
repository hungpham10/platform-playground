locals {
  inventory = {
    all = {
      hosts = {
        for i in range(0, var.metric) : var.instances[i] => merge(
          {
            ansible_host            = var.instances[i]
            ansible_user            = var.username
            ansible_password        = var.password
            instance_role           = var.role
            net                     = var.net
            domain                  = var.instances[i]
            network_interfaces      = var.network
          },
          var.variables,
        )
      }
    }
  }
}
