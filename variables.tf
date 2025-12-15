########################################################################################################################
# Input Variables
########################################################################################################################

variable "region" {
  type        = string
  description = "Region where resources are created"
}

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group to use for the creation of the Terraform Enterprise instance and the related resources."
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access tags to be added to created resources"
  default     = []
}

##############################################################################
# TFE
##############################################################################

variable "tfe_license" {
  type        = string
  description = "The license key for TFE"
  default     = null
  sensitive   = true
}

variable "tfe_license_secret_crn" {
  type        = string
  description = "The CRN of the Secrets Manager secret containing the license key for TFE"
  default     = null

  validation {
    condition     = !(var.tfe_license == null && var.tfe_license_secret_crn == null)
    error_message = "Exactly one of `tfe_license_secret_crn` or `tfe_license` must be set"
  }

  validation {
    condition     = !(var.tfe_license != null && var.tfe_license_secret_crn != null)
    error_message = "Only one of `tfe_license_secret_crn` or `tfe_license` must be set"
  }

  validation {
    condition = anytrue([
      var.tfe_license_secret_crn == null,
      can(regex("^crn:v\\d:(.*:){2}secrets-manager:(.*:)([aos]\\/[\\w_\\-]+):[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}:secret:[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.tfe_license_secret_crn))
    ])
    error_message = "The value provided for 'tfe_license_secret_crn' is not valid."
  }
}

variable "admin_username" {
  type        = string
  description = "The user name of the TFE admin user"
}

variable "admin_email" {
  type        = string
  description = "The email address of the TFE admin user"
}

variable "admin_password" {
  type        = string
  description = "The password for the TFE admin user"
  sensitive   = true
}

variable "tfe_namespace" {
  type        = string
  description = "namespace to place TFE in on cluster"
  default     = "tfe"
}

variable "tfe_organization" {
  type        = string
  description = "If set, the name of the TFE organization to create. If not set, the module will not create an organization."
  default     = "default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,63}$", var.tfe_organization))
    error_message = "The TFE organization name must only contain letters, numbers, underscores (_), and hyphens (-), and must not exceed 63 characters."
  }
}

variable "add_to_catalog" {
  type        = bool
  description = "Whether to add this instance as an engine to your account's catalog settings. Defaults to true. MAY CONFLICT WITH EXISTING INSTANCES YOUR IN CATALOG SETTINGS."
  default     = true
}

variable "terraform_enterprise_engine_name" {
  type        = string
  description = "Name to give to the Terraform Enterprise engine in account catalog settings. Defaults to 'tfe-engine' if not set."
  nullable    = false
  default     = "tfe-engine"
  validation {
    condition     = var.terraform_enterprise_engine_name != ""
    error_message = "var.terraform_enterprise_engine_name cannot be set to an empty string."
  }
}

variable "enable_automatic_deployable_architecture_creation" {
  type        = bool
  description = "Whether to automatically create Deployable Architectures in associated private catalog from workspace."
  default     = false
}

variable "default_private_catalog_id" {
  type        = string
  description = "If `enable_deployable_architecture_creation` is true, specify the private catalog ID to create the Deployable Architectures in."
  default     = null

  validation {
    condition     = var.enable_automatic_deployable_architecture_creation != true ? true : var.default_private_catalog_id != null
    error_message = "Must specific a `default_private_catalog_id` if `enable_deployable_architecture_creation` is true."
  }
}

variable "terraform_engine_scopes" {
  type = list(object({
    name = string,
    type = string
  }))
  description = "List of scopes to auto-create deployable architectures from workspaces in the engine."
  default     = []
  nullable    = false
}

##############################################################################
# KMS
##############################################################################

variable "kms_instance_name" {
  type        = string
  description = "Name of KMS Key Protect instance to create. Default to tfe-kms-kp."
  default     = "tfe-kms-kp"
}

##############################################################################
# COS
##############################################################################

variable "existing_cos_instance_id" {
  type        = string
  description = "Existing COS instance to pass in. If set to `null`, a new instance will be created."
  default     = null
}

variable "cos_instance_name" {
  type        = string
  description = "Name of COS instance to create. Default to tfe-cos. If var.existing_cos_instance_id is not null this value is ignored. Null allowed only if var.existing_cos_instance_id is not null."
  default     = "tfe-cos"

  validation {
    condition     = var.existing_cos_instance_id == null && var.cos_instance_name == null ? false : true
    error_message = "var.existing_cos_instance_id and var.cos_instance_name cannot be both null."
  }
}

variable "cos_bucket_name" {
  type        = string
  nullable    = false
  description = "Name of the bucket to create in COS instance. Default to tfe-cos-bucket"
  default     = "tfe-cos-bucket"
}

variable "cos_retention" {
  type        = bool
  description = "Whether retention for the Object Storage bucket is enabled. Enable for staging and prod environments."
  default     = false
}

##############################################################################
# PostGres
##############################################################################

variable "postgres_instance_name" {
  type        = string
  description = "Name of postgres instance to create. Default set to be `tfe-data-store`"
  default     = "tfe-data-store"
}

variable "postgres_deletion_protection" {
  type        = bool
  description = "Enable deletion protection within terraform. This is not a property of the resource and does not prevent deletion outside of terraform. The database can not be deleted by terraform when this value is set to 'true'. In order to delete with terraform the value must be set to 'false' and a terraform apply performed before the destroy is performed. The default is 'true'."
  default     = true
}

##############################################################################
# Redis
##############################################################################

variable "existing_redis_hostname" {
  type        = string
  description = "Hostname of the existing redis instance to integrate with the Terraform Enterprise instance. If set to null a new redis instance is deployed in the cluster. Default to null."
  default     = null
}

variable "existing_redis_password_base64" {
  type        = string
  description = "Base64 encoded password for the existing redis instance. Default to null."
  default     = null
  sensitive   = true

  validation {
    condition     = var.existing_redis_hostname != null ? var.existing_redis_password_base64 != null : true
    error_message = "If var.existing_redis_hostname is set, var.existing_redis_password_base64 must also be set."
  }
}

variable "redis_password_secret_name" {
  type        = string
  description = "The name of the Secrets Manager secret to store the redis password if var.existing_secrets_manager_crn is not null. Default to tfe_redis_password."
  default     = "tfe_redis_password"
  validation {
    condition     = var.existing_secrets_manager_crn == null ? true : (var.redis_password_secret_name != null && var.redis_password_secret_name != "" ? true : false)
    error_message = "If var.existing_secrets_manager_crn is not null var.redis_password_secret_name cannot be null or empty string."
  }
}

##############################################################################
# VPC/OCP
##############################################################################

variable "existing_vpc_id" {
  type        = string
  description = "The ID of the existing vpc. If not set, a new VPC will be created."
  default     = null
}

variable "existing_cluster_id" {
  type        = string
  description = "The ID of the existing cluster. If not set, a new cluster will be created."
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

##############################################################################
# Secrets Manager
##############################################################################

variable "existing_secrets_manager_crn" {
  type        = string
  description = "The CRN of the existing Secrets Manager instance. If not set, secrets will not be stored in a Secrets Manager instance."
  default     = null

  validation {
    condition = anytrue([
      var.existing_secrets_manager_crn == null,
      can(regex("^crn:v\\d:(.*:){2}secrets-manager:(.*:)([aos]\\/[\\w_\\-]+):[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_secrets_manager_crn))
    ])
    error_message = "The value provided for 'existing_secrets_manager_crn' is not valid."
  }
}

variable "existing_secrets_manager_secret_group_id" {
  type        = string
  description = "The existing secrets group ID to store secrets in. If not set, secrets will be stored in `var.secrets_manager_secret_group_name` secret group."
  default     = null

  validation {
    condition = (
      !(var.existing_secrets_manager_crn == null &&
      var.existing_secrets_manager_secret_group_id != null)
    )
    error_message = "`secrets_manager_secret_group_id` is not required when `secrets_manager_crn` is not specified."
  }

  validation {
    condition = anytrue([
      var.existing_secrets_manager_secret_group_id == null,
      var.existing_secrets_manager_secret_group_id == "default",
      can(regex("^[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}", var.existing_secrets_manager_secret_group_id))
    ])
    error_message = "The value provided for 'existing_secrets_manager_secret_group_id' is not valid."
  }
}

variable "secrets_manager_secret_group_name" {
  type        = string
  description = "The secrets group name to create to store secrets in var.existing_secrets_manager_crn if var.existing_secrets_manager_secret_group_id is null."
  default     = "tfe-secrets-group"
  validation {
    condition     = var.existing_secrets_manager_secret_group_id != null || var.secrets_manager_secret_group_name != null
    error_message = "var.secrets_manager_secret_group_name and var.existing_secrets_manager_secret_group_id cannot be both null."
  }
}
