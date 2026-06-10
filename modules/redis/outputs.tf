##############################################################################
# Redis outputs
##############################################################################

output "redis_password_base64" {
  description = "Base64 encoded Redis password"
  value       = base64encode(module.icd_redis.service_credentials_object.credentials["tfe"].password)
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
  description = "Base64 encoded TLS certificate for Redis connection (already base64 encoded by IBM Cloud)"
  value       = module.icd_redis.service_credentials_object.credentials["tfe"].connection.rediss.certificate.certificate_base64
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
