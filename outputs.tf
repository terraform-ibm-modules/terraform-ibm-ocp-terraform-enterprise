########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  value       = var.resource_group_id
  description = "The ID of the provisioned resource group."
}

output "cos_instance_id" {
  value       = module.cos.cos_instance_id
  description = "The name of the provisioned cos instance."
}

output "cluster_id" {
  value       = module.ocp_vpc.cluster_id
  description = "The ID of the provisioned cluster."
}

output "postgres_crn" {
  value       = module.icd_postgres.crn
  description = "The CRN of the provisioned postgres instance."
}

output "redis_host" {
  value       = local.redis_host
  description = "The name of the provisioned redis host."
}

output "redis_password" {
  value       = var.existing_secrets_manager_crn == null ? local.redis_pass_base64 : null
  description = "password to redis instance, this is set to null when a value for `existing_secrets_manager_crn` is provided"
  sensitive   = true
}

output "tfe_console_url" {
  value       = module.tfe_install.tfe_console_url
  description = "url to access Terraform Enterprise."
}

output "tfe_hostname" {
  value       = module.tfe_install.tfe_hostname
  description = "The hostname for Terraform Enterprise instance"
}

output "redis_password_secret_crn" {
  value       = var.existing_secrets_manager_crn != null ? module.redis_password_secret[0].secret_crn : null
  description = "The CRN of the secret containing the redis admin password"
}

output "tfe_secondary_hostname_fqdn" {
  description = "The FQDN for the Terraform Enterprise secondary hostname. Null if no secondary hostname is created"
  value       = var.tfe_secondary_host != null ? "https://${local.tfe_secondary_hostname_fqdn}" : null
}
