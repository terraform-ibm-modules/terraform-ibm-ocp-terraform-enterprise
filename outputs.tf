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

output "vpc_id" {
  value       = module.ocp_vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_subnets" {
  description = "The subnets of the VPC, including the ID, the subnet zone and the subnet CIDR."
  value = { for subnet in module.ocp_vpc.vpc_subnet_zone_list :
    subnet.name => {
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.cidr
    }
  }
}

output "cluster_id" {
  value       = module.ocp_vpc.cluster_id
  description = "The name of the provisioned cluster."
}

output "icd_postgres_hostname" {
  description = "The hostname of the provisioned Postgres instance."
  value       = module.icd_postgres.hostname
}

output "icd_postgres_port" {
  description = "The port of the provisioned Postgres instance listens on."
  value       = module.icd_postgres.port
}

output "icd_postgres_crn" {
  value       = module.icd_postgres.crn
  description = "The crm of the provisioned Postgres instance."
}

output "icd_postgres_vpe" {
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

output "final_acl_rules" {
  description = "The final set of ACL rules applied to the VPC, including any rules added for Postgres connectivity."
  value       = local.final_acl_rules
}

output "kube_cluster_sg" {
  description = "The ID of the default security group representing the cluster nodes."
  value       = module.ocp_vpc.kube_cluster_sg.id
}

output "vpc_default_security_group" {
  description = "The ID of the VPC default security group."
  value       = module.ocp_vpc.vpc_default_security_group
}

output "vpc_kubecluster_sg_rule" {
  description = "The Security group rule going to be attached to the cluster default Security Group in order to enable Postegres connectivity."
  value       = ibm_is_security_group_rule.vpc_kubecluster_sg_rule
}
