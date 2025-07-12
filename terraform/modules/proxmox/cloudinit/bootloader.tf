locals {
  bootloader_init_step = length(var.installer) > 0? "init_using_installer": "init_using_git"

  bootloader_arguments = {
    installer = "--steps init_using_git;include_libraries;setup_dependencies;perform_setup_playbook"
    gateway   = "--steps ${bootloader_init_step};include_libraries;setup_dependencies;perform_setup_playbook"
    default   = "--steps ${bootloader_init_step};include_libraries;setup_dependencies;perform_setup_playbook" # Default if node_type doesn't match
  }
}