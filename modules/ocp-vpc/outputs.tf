########################################################################################################################
# Outputs
########################################################################################################################

output "cluster_name" {
  value       = local.cluster_name
  description = "The name of the provisioned cluster."
}

output "cluster_id" {
  value       = local.cluster_id
  description = "The ID of the provisioned cluster."
}

output "ingress_hostname" {
  value       = local.ingress_hostname
  description = "The hostname of the cluster's ingress controller."
}

output "vpc_id" {
  value       = local.vpc_id
  description = "The ID of the VPC used by the cluster."
}

output "vpc_name" {
  value       = local.vpc_name
  description = "The ID of the VPC used by the cluster."
}

output "vpc_subnet_zone_list" {
  value       = module.vpc.subnet_zone_list
  description = "The list of subnets created for the VPC."
}

output "security_group_details" {
  value       = module.vpc.security_group_details
  description = "The details of security group added to the VPC."
}
