output "token" {
  description = "The temporary google cloud platform access token"
  value       = data.google_service_account_access_token.sa.access_token
}
