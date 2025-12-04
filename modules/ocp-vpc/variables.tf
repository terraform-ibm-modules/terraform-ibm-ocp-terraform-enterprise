########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  type        = string
  description = "The Resource Group ID to use for all resources created in this solution (VPC and cluster)"
  default     = null
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "eu-es"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the resources created by the module"
  default     = []
}

variable "ocp_version" {
  type        = string
  description = "Version of the OCP cluster to provision"
  default     = null
}

variable "ocp_entitlement" {
  type        = string
  description = "Value that is applied to the entitlements for OCP cluster provisioning"
  default     = null
}

variable "existing_vpc_id" {
  type        = string
  description = "The ID of the existing vpc. If not set, a new VPC will be created."
  default     = null
}

variable "existing_cluster_id" {
  type        = string
  description = "The CRN of the existing cluster. If not set, a new cluster will be created."
  default     = null
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to create. Default to tfe-vpc. If var.existing_vpc_id is not null this value is ignored. Null allowed only if var.existing_vpc_id is not null."
  default     = "tfe-vpc"
  validation {
    condition     = var.existing_vpc_id == null && var.vpc_name == null ? false : true
    error_message = "var.existing_vpc_id and var.vpc_name cannot be both null."
  }
}

variable "cluster_name" {
  type        = string
  description = "Name of the OCP cluster to create. Default to tfe-cluster. If var.existing_cluster_id is not null this value is ignored. Null allowed only if var.existing_cluster_id is not null."
  default     = "tfe-cluster"
  nullable    = false
  validation {
    condition     = var.existing_cluster_id == null && var.cluster_name == null ? false : true
    error_message = "var.existing_cluster_id and var.cluster_name cannot be both null."
  }
}
