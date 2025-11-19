locals {
  bootloader_init_step = length(var.installer) > 0? "init_using_installer": "init_using_local_storage"

  bootloader_arguments = {
    installer = "--steps init_using_local_storage,include_libraries,perform_setup_playbook"
    gateway   = "--steps ${local.bootloader_init_step},include_libraries,perform_setup_playbook"
    default   = "--steps ${local.bootloader_init_step},include_libraries,perform_setup_playbook" # Default if node_type doesn't match
  }
}
