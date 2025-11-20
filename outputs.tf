########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "The name of the provisioned cos instance."
}

output "cos_instance_id" {
  value       = module.cos.cos_instance_id
  description = "The name of the provisioned cos instance."
}

output "cluster_id" {
  value       = module.ocp_vpc.cluster_id
  description = "The name of the provisioned cluster."
}

output "postgres_crn" {
  value       = module.icd_postgres.crn
  description = "The crm of the provisioned postgres instance."
}

output "postgres_vpe" {
  value       = module.icd_postgres_vpe
  description = "Details of the Virtual Private Endpoint created towards postgres instance"
}

output "redis_host" {
  value       = local.redis_host
  description = "The name of the provisioned redis host."
}

output "redis_password" {
  value       = local.redis_pass_base64
  description = "password to redis instance"
  sensitive   = true
}

output "tfe_console_url" {
  value       = module.tfe_install.tfe_console_url
  description = "url to access TFE."
}

output "tfe_hostname" {
  value       = module.tfe_install.tfe_hostname
  description = "The hostname for TFE instance"
}

output "token" {
  value       = nonsensitive(module.tfe_install.token)
  description = "The token for TFE instance"
  sensitive   = false
}
