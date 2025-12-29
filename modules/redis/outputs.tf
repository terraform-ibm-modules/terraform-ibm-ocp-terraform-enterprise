output "redis_password_base64" {
  description = "Base64 encoded Redis password"
  value       = data.kubernetes_secret_v1.redis_password.data["redis-password"]
  sensitive   = true
}

output "redis_host" {
  description = "The Redis host for TFE"
  value       = "${local.release_name}-master.${local.namespace}.svc.cluster.local"
}
