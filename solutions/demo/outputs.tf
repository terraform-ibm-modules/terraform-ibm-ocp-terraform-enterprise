########################################################################################################################
# Outputs
########################################################################################################################

output "cos_instance_id" {
  value       = module.tfe.cos_instance_id
  description = "The name of the provisioned cos instance."
}

output "vpc_id" {
  value       = module.tfe.vpc_id
  description = "The ID of the provisioned VPC."
}

output "cluster_id" {
  value       = module.tfe.cluster_id
  description = "The name of the provisioned cluster."
}

output "icd_postgres_hostname" {
  description = "The hostname of the provisioned Postgres instance"
  value       = module.tfe.icd_postgres_hostname
}

output "icd_postgres_port" {
  value       = module.tfe.icd_postgres_port
  description = "The port the provisioned Postgres instance listens on."
}

output "icd_postgres_crn" {
  value       = module.tfe.icd_postgres_crn
  description = "The crn of the provisioned Postgres instance."
}

output "icd_postgres_vpe" {
  description = "Details for the Virtual Private Endpoint created to Postgres."
  value       = module.tfe.icd_postgres_vpe
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

output "vpc_subnets" {
  description = "The subnets of the VPC, including the ID, the subnet zone and the subnet CIDR."
  value       = module.tfe.vpc_subnets
}

output "kube_cluster_sg" {
  description = "The ID of the default security group representing the cluster nodes."
  value       = module.tfe.kube_cluster_sg
}

output "vpc_default_security_group" {
  description = "The ID of the VPC default security group."
  value       = module.tfe.vpc_default_security_group
}

output "vpc_kubecluster_sg_rule" {
  description = "The Security group rule attached to the cluster default Security Group in order to enable Postgres connectivity."
  value       = module.tfe.vpc_kubecluster_sg_rule
}

output "final_acl_rules" {
  description = "The final set of ACL rules applied to the VPC, including any rules added for Postgres connectivity."
  value       = module.tfe.final_acl_rules
}
