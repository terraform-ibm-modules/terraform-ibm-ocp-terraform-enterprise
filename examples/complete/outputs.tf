########################################################################################################################
# Outputs
########################################################################################################################

output "cos_instance_id" {
  value       = module.tfe.cos_instance_id
  description = "The name of the provisioned cos instance."
}

output "cluster_id" {
  value       = module.tfe.cluster_id
  description = "The name of the provisioned cluster."
}

output "postgres_crn" {
  value       = module.tfe.postgres_crn
  description = "The crm of the provisioned postgres instance."
}

output "redis_host" {
  value       = module.tfe.redis_host
  description = "The name of the provisioned redis host."
}

output "redis_password" {
  value       = module.tfe.redis_password
  description = "password to redis instance"
  sensitive   = true
}

output "tfe_console_url" {
  value       = module.tfe.tfe_console_url
  description = "url to access TFE."
}

output "tfe_hostname" {
  value       = module.tfe.tfe_hostname
  description = "hostname of TFE"
}

output "redis_password_secret_crn" {
  value       = module.tfe.redis_password_secret_crn
  description = "The CRN of the secret containing the redis admin password"
}

output "tfe_custom_domain" {
  description = "The full custom hostname if created"
  value       = var.tfe_custom_hostname != null ? module.tfe.tfe_custom_domain : null
}
