terraform {
  required_version = ">= 1.8"
  required_providers {
    helpers = {
      source = "inventium-tech/helpers"
      version = "1.4.0"
    }
  }
}

output "telegram" {
  value = {
    token   = provider::helpers::os_get_env("TELEGRAM_TOKEN")
    chat_id = provider::helpers::os_get_env("TELEGRAM_CHAT_ID")
  }
}
  
output "promtail" {
  value = {
    username = provider::helpers::os_get_env("PROMTAIL_USERNAME")
    password = provider::helpers::os_get_env("PROMTAIL_PASSWORD")
    endpoint = provider::helpers::os_get_env("PROMTAIL_ENDPOINT")
    messages = provider::helpers::os_get_env("PROMTAIL_WELCOME_MESSAGE")
  }
}

output "access_token" {
  value = provider::helpers::os_get_env("ACCESS_TOKEN_OF_PLAYBOOKS")
}

output "tag" {
  value = provider::helpers::os_get_env("TAG_OF_MONO_REPOSITORY")
}

output "username" {
  value = provider::helpers::os_get_env("USERNAME_TO_START_PLAYBOOK")
}

output "password" {
  value = provider::helpers::os_get_env("PASSWORD_TO_START_PLAYBOOK")
}
