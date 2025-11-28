##############################################################################
# Outputs
##############################################################################
output "tfe_installation_status" {
  description = "The status of the Terraform Enterprise installation"
  value       = helm_release.tfe_install.status
}

output "tfe_console_url" {
  description = "The URL to access the Terraform Enterprise console"
  value       = "https://${data.kubernetes_resource.tfe_route.object.status.ingress[0].host}"
}

output "tfe_hostname" {
  description = "The hostname for Terraform Enterprise instance"
  value       = data.kubernetes_resource.tfe_route.object.status.ingress[0].host
}

output "token" {
  description = "A Terraform Enterprise user API token for `var.admin_username` account"
  value       = resource.kubernetes_secret.tfe_admin_token.data["token"]
  sensitive   = true
}
