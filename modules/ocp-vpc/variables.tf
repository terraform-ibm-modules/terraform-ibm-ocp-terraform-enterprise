########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  type        = string
  description = "The Resource Group ID to use for all resources created in this solution (VPC and cluster)"
  default     = null
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
  default = "tfe"
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

#variable "kms_config" {
#  type = object({
#    crk_id           = string
#    instance_id      = string
#    private_endpoint = optional(bool, true) # defaults to true
#    account_id       = optional(string)     # To attach KMS instance from another account
#    wait_for_apply   = optional(bool, true) # defaults to true so terraform will wait until the KMS is applied to the master, ready and deployed
#  })
#  description = "Use to attach a KMS instance to the cluster. If account_id is not provided, defaults to the account in use."
#  default     = null
#}
