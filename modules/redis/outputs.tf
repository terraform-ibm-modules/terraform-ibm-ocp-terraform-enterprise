##############################################################################
# Redis outputs
##############################################################################

output "redis_password_base64" {
  description = "Base64-encoded Redis password for the TFE service credential"
  value       = base64encode(module.icd_redis.service_credentials_object.credentials["tfe"].password)
  sensitive   = true
}

output "redis_username" {
  description = "The Redis username"
  value       = module.icd_redis.service_credentials_object.credentials["tfe"].username
  sensitive   = true
}

output "redis_host" {
  description = "The Redis host for TFE"
  value       = module.icd_redis.hostname
}

output "redis_port" {
  description = "The Redis port"
  value       = module.icd_redis.port
}

output "redis_certificate_base64" {
  description = "Base64 encoded TLS certificate for Redis connection"
  value       = module.icd_redis.certificate_base64
  sensitive   = true
}

output "redis_id" {
  description = "The ID of the Redis instance"
  value       = module.icd_redis.id
}

output "redis_crn" {
  description = "The CRN of the Redis instance"
  value       = module.icd_redis.crn
}
